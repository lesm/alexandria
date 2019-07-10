require 'rails_helper'

RSpec.describe PublishersController, type: :request do
  let(:key) { create(:api_key).key }
  let(:headers) do
    { 'AUTHORIZATION' => "Alexandria-Token api_key=#{key}" }
  end

  let(:publisher_1) do
    create :publisher, :with_p_book, name: 'MacMilla'
  end
  let(:publisher_2) { create :publisher, :with_p_book }
  let(:publisher_3) { create :publisher, :with_p_book }
  let(:publishers) { [publisher_1, publisher_2, publisher_3] }

  describe 'GET /api/publishers' do
    before { publishers }

    context 'default behavior' do
      before { get '/api/publishers', headers: headers }

      it 'receives HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it "receives a json with the 'data' root key" do
          expect(json_body['data']).not_to be_nil
      end

      it 'receives all 3 publishers' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before do
          get '/api/publishers?fields=id,name', headers: headers
        end

        it 'gets publishers with only the id, name' do
          json_body['data'].each do |publisher|
            expect(publisher.keys).to eq ['id', 'name']
          end
        end
      end

      context "without 'fields' parameter" do
        before { get '/api/publishers/', headers: headers }

        it 'gets publishers with all the fields specified in the presenter' do
          json_body['data'].each do |publisher|
            expect(publisher.keys).to eq PublisherPresenter.build_attributes
          end
        end
      end

      context "with invalid fields name 'fid'" do
        before do
          get '/api/publishers?fields=fid,name', headers: headers
        end

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
        before { get '/api/publishers?embed=books', headers: headers }

        it 'gets the publishers with their books embeded' do
          json_body['data'].each do |publisher|
            expect(publisher['books'].first.keys).to eq (
              %w(id title subtitle isbn_10 isbn_13 description
              released_on publisher_id author_id created_at
              updated_at cover)
            )
          end
        end
      end

      context "with invalid 'embed' relation 'fake'" do
        before { get '/api/publishers?embed=fake', headers: headers }

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
        before { get '/api/publishers?page1&per=2', headers: headers }

        it 'receives HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'receives only two publishers' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq '<http://www.example.com/api/publishers?page=2&per=2>; rel="next"'
        end
      end

      context 'when asking for the second page' do
        before { get '/api/publishers?page=2&per=2', headers: headers }

        it 'receives HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'receives only one publisher' do
          expect(json_body['data'].size).to eq 1
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq '<http://www.example.com/api/publishers?page=1&per=2>; rel="first"'
        end
      end

      context "when sending invalid 'page' and 'per' parameters" do
        before { get '/api/publishers?page=fake&per=10', headers: headers }

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
        it "sorts the publishers by 'id desc'" do
          get '/api/publishers?sort=id&dir=desc', headers: headers
          expect(json_body['data'].first['id']).to eq publisher_3.id
          expect(json_body['data'].last['id']).to eq publisher_1.id
        end
      end
      context "with invalid column name 'fid'" do
        before { get '/api/publishers?sort=fid&dir=asc', headers: headers }

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
      context "with valid filtering param 'q[name_cont]'" do
        it "receives 'MacMilla' publisher back" do
          get "/api/publishers?q[name_cont]=MacMilla", headers: headers
          expect(json_body['data'].first['id']).to eq publisher_1.id
          expect(json_body['data'].size).to eq 1
        end
      end

      context "with invalid filtering param 'q[fname_cont]'" do
        before { get '/api/publishers?q[fname_cont]=MacMilla', headers: headers }

        it 'gets 400 Bad Request back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'q[fname_cont]=MacMilla' as an invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'q[fname_cont]=MacMilla'
        end
      end
    end
  end

  describe 'GET /api/publishers/:id' do
    context 'with existing resource' do
      before { get "/api/publishers/#{publisher_1.id}", headers: headers }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'receives the publisher_1 as JSON' do
        expected = { data: PublisherPresenter.new(publisher_1, {}).fields.embeds }
        expect(response.body).to eq expected.to_json
      end
    end

    context 'with nonexistent resource' do
      before { get "/api/publishers/89898989", headers: headers }

      it 'gets HTTP status 404' do
        expect(response).to have_http_status 404
      end

      it 'receives an error json message' do
        expect(json_body['error']).to_not be_nil
      end
    end
  end

  describe 'POST /api/publishers' do
    before { post '/api/publishers', params: { data: params }, headers: headers }

    context 'with valid params' do
      let(:params) { attributes_for :publisher }

      it 'gets HTTP status 201' do
        expect(response).to have_http_status 201
      end

      it 'receives the newly created resource' do
        expect(json_body['data']['name']).to eq params[:name]
      end

      it 'adds a record in the database' do
        expect(Publisher.count).to eq 1
      end

      it 'gets the new resource location in the Location header' do
        expect(response.headers['Location']).to eq(
          "http://www.example.com/api/publishers/#{Publisher.first.id}")
      end
    end

    context 'with invalid params' do
      let(:params) { attributes_for :publisher, name: '' }

      it 'gets HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'receives an error details' do
        expect(json_body['error']['invalid_params']).to eq(
          {"name" => ["can't be blank"] }
        )
      end

      it 'does not add a record in the database' do
        expect(Publisher.count).to eq 0
      end
    end
  end

  describe 'PATCH /api/publishers/:id' do
    before do
      patch "/api/publishers/#{publisher_1.id}", params: { data: params }, headers: headers
    end

    context 'with valid params' do
      let(:params) { { name: 'Prisma' } }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it "receives the updated resource" do
        expect(json_body['data']['name']).to eq "Prisma"
      end

      it 'updates the record in the database' do
        expect(Publisher.first.name).to eq 'Prisma'
      end
    end

    context 'with invalid params' do
      let(:params) { { name: '' } }

      it 'gets HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'receives an error details' do
        expect(json_body['error']['invalid_params']).to eq(
          {"name" => ["can't be blank"]}
        )
      end

      it "doesn't update the record in the database" do
        expect(Publisher.first.name).to eq 'MacMilla'
      end
    end
  end

  describe 'DELETE /api/publishers/:id' do
    context 'with existing resource' do
      let(:publisher) { create :publisher }
      before { delete "/api/publishers/#{publisher.id}", headers: headers }

      it 'gets HTTP status 204' do
        expect(response.status).to eq 204
      end

      it 'deletes the publisher from the database' do
        expect(Publisher.count).to eq 0
      end
    end

    context 'with existing resource with dependencies' do
    end

    context 'with nonexistent resource' do
      it 'gets HTTP status 404' do
        delete '/api/publishers/898989', headers: headers
        expect(response).to have_http_status 404
      end
    end
  end
end
