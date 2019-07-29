require 'rails_helper'

RSpec.describe AuthorsController, type: :request do
  let(:api_key) { create(:api_key) }
  let(:token) do
    "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}"
  end
  let(:headers) { { 'AUTHORIZATION' => token } }

  let(:pat) { create :author, :with_a_book, given_name: 'Perez' }
  let(:michael) { create :author, :with_a_book }
  let(:sam) { create :author, :with_a_book }
  let(:authors) { [pat, michael, sam] }

  describe 'GET /api/authors' do
    before { authors }

    context 'default behaviour' do
      before { get '/api/authors', headers: headers }

      it 'receives HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it "receives a json with the 'data' root key" do
          expect(json_body['data']).not_to be_nil
      end

      it 'receives all 3 authors' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before { get '/api/authors?fields=id,given_name,family_name', headers: headers }

        it 'gets authors with only the id, given_name, family_name' do
          json_body['data'].each do |book|
            expect(book.keys).to eq ['id', 'given_name', 'family_name']
          end
        end
      end

      context "without 'fields' parameter" do
        before { get '/api/authors/', headers: headers }

        it 'gets authors with all the fields specified in the presenter' do
          json_body['data'].each do |book|
            expect(book.keys).to eq AuthorPresenter.build_attributes
          end
        end
      end

      context "with invalid fields name 'fid'" do
        before { get '/api/authors?fields=fid,given_name,family_name', headers: headers }

        it 'gets 400 Bad Request back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end
      end
    end

    describe 'embed picking' do
      context "with the 'embed' parameter" do
        before { get '/api/authors?embed=books', headers: headers }

        it 'gets the authors with their books embeded' do
          json_body['data'].each do |author|
            expect(author['books'].first.keys).to eq (
              %w(id title subtitle isbn_10 isbn_13 description
              released_on publisher_id author_id created_at
              updated_at cover)
            )
          end
        end
      end

      context "with invalid 'embed' relation 'fake'" do
        before { get '/api/authors?embed=fake', headers: headers }

        it 'gets 400 Bad Reques back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'fields=fid as an invalid param'" do
          expect(json_body['error']['invalid_params']).to eq 'embed=fake'
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get '/api/authors?page1&per=2', headers: headers }

        it 'receives HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'receives only two authors' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq '<http://www.example.com/api/authors?page=2&per=2>; rel="next"'
        end
      end

      context 'when asking for the second page' do
        before { get '/api/authors?page=2&per=2', headers: headers }

        it 'receives HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'receives only one author' do
          expect(json_body['data'].size).to eq 1
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq '<http://www.example.com/api/authors?page=1&per=2>; rel="first"'
        end
      end

      context "when sending invalid 'page' and 'per' parameters" do
        before do
          get '/api/authors?page=fake&per=10', headers: headers
        end

        it 'receives HTTP status 400' do
          expect(response).to have_http_status 400
        end

        it 'receives an error key' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'page=fake' as an invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'page=fake'
        end
      end
    end

    describe 'sorting' do
      context "with valid column name 'id'" do
        it "sorts the authors by 'id desc'" do
          get '/api/authors?sort=id&dir=desc', headers: headers
          expect(json_body['data'].first['id']).to eq sam.id
          expect(json_body['data'].last['id']).to eq pat.id
        end
      end

      context "with invalid column name 'fid'" do
        before do
          get '/api/authors?sort=fid&dir=asc', headers: headers
        end

        it 'gets "400 Bad Request" back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it "receives 'sort=fid' as an invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'sort=fid'
        end
      end
    end

    describe 'filtering' do
      context "with valid filtering param 'q[given_name_cont]'" do
        it "receives 'Perez' back" do
          get "/api/authors?q[given_name_cont]=Perez", headers: headers
          expect(json_body['data'].first['id']).to eq pat.id
          expect(json_body['data'].size).to eq 1
        end
      end

      context "with invalid filtering param 'q[fgiven_name_cont]'" do
        before do
          get '/api/authors?q[fgiven_name_cont]=Perez', headers: headers
        end

        it 'gets "400 Bad Request" back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'q[fgiven_name_cont]=Perez' as an invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'q[fgiven_name_cont]=Perez'
        end
      end
    end
  end

  describe 'GET /api/authors/:id' do
    context 'with existing resource' do
      before { get "/api/authors/#{pat.id}", headers: headers }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'receives the book_1 as JSON' do
        expected = { data: AuthorPresenter.new(pat, {}).fields.embeds }
        expect(response.body).to eq expected.to_json
      end
    end

    context 'with nonexistent resource' do
      before { get '/api/authors/89898989', headers: headers }

      it 'gets HTTP status 404' do
        expect(response).to have_http_status 404
      end

      it 'receives an error json message' do
        expect(json_body['error']).to_not be_nil
      end
    end
  end

  describe 'POST /api/authors' do
    before do
      post '/api/authors', params: { data: params }, headers: headers
    end

    context 'with valid params' do
      let(:params) { attributes_for :author }

      it 'gets HTTP status 201' do
        expect(response).to have_http_status 201
      end

      it 'receives the newly created resource' do
        expect(json_body['data']['given_name']).to eq params[:given_name]
      end

      it 'adds a record in the database' do
        expect(Author.count).to eq 1
      end

      it 'gets the new resource location in the Location header' do
        expect(response.headers['Location']).to eq(
          "http://www.example.com/api/authors/#{Author.first.id}")
      end
    end

    context 'with invalid params' do
      let(:params) { attributes_for :author, given_name: '' }

      it 'gets HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'receives an error details' do
        expect(json_body['error']['invalid_params']).to eq(
          {"given_name" => ["can't be blank"] }
        )
      end

      it 'does not add a record in the database' do
        expect(Author.count).to eq 0
      end
    end
  end

  describe 'PATCH /api/authors/:id' do
    before do
      patch "/api/authors/#{pat.id}", params: { data: params }, headers: headers
    end

    context 'with valid params' do
      let(:params) { { given_name: 'Pepito' } }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it "receives the updated resource" do
        expect(json_body['data']['given_name']).to eq "Pepito"
      end

      it 'updates the record in the database' do
        expect(Author.first.given_name).to eq 'Pepito'
      end
    end

    context 'with invalid params' do
      let(:params) { { given_name: '' } }

      it 'gets HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'receives an error details' do
        expect(json_body['error']['invalid_params']).to eq(
          {"given_name" => ["can't be blank"]}
        )
      end

      it "doesn't update the record in the database" do
        expect(Author.first.given_name).to eq 'Perez'
      end
    end
  end

  describe 'DELETE /api/authors/:id' do
    context 'with existing resource' do
      let(:author) { create :author }
      before { delete "/api/authors/#{author.id}", headers: headers }

      it 'gets HTTP status 204' do
        expect(response.status).to eq 204
      end

      it 'deletes the record from the database' do
        expect(Author.count).to eq 0
      end
    end

    context 'with existing resource with dependencies' do
    end

    context 'with nonexistent resource' do
      it 'gets HTTP status 404' do
        delete '/api/authors/898989', headers: headers
        expect(response).to have_http_status 404
      end
    end
  end
end
