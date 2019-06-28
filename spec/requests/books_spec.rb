require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:book_1) do
    create :book,
      title: 'Ruby Under a Microscope',
      released_on: '2013-05-9'
  end
  let(:book_2) do
    create :book, title: 'Second book', released_on: '2014-09-9'
  end
  let(:book_3) do
    create :book, title: 'Third book', released_on: '2015-05-6'
  end
  let(:books) { [book_1, book_2, book_3] }

  describe 'GET /api/books' do
    before { books }

    context 'default behavior' do
      before { get '/api/books' }
      it 'receives HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it 'receices a json with the "data" root key' do
        expect(json_body['data']).to_not be_nil
      end

      it 'receives all 3 books' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context "with the 'fields' parameter" do
        before { get '/api/books?fields=id,title,author_id'}

        it 'gets books with only the id, title, author_id keys' do
          json_body['data'].each do |book|
            expect(book.keys).to eq ['id','title','author_id']
          end
        end
      end

      context "without 'fields' parameter" do
        before { get '/api/books' }

        it "gets books with all the fields specified in the presenter" do
          json_body['data'].each do |book|
            expect(book.keys).to eq BookPresenter.build_attributes
          end
        end
      end

      context "with invalid field name 'fid'" do
        before { get '/api/books?fields=fid,title,author_id' }

        it 'gets 400 Bad Request back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'fields=fid' as invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'fields=fid'
        end
      end
    end

    describe 'embed picking' do
      context "with the 'embed' parameter" do
        before { get '/api/books?embed=author' }

        it 'gets the books with their authors embeded' do
          json_body['data'].each do |book|
            expect(book['author'].keys).to eq(
              %w(id given_name family_name created_at updated_at))
          end
        end
      end

      context "with invalid 'embed' relation 'fake'" do
        before { get '/api/books?embed=fake,author' }

        it 'gets 400 Bad Request back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'fields=fid' as an invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'embed=fake'
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get('/api/books?page=1&per=2') }

        it 'receives HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'receives only two books' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq '<http://www.example.com/api/books?page=2&per=2>; rel="next"'
        end
      end

      context 'when asking for the second page' do
        before { get('/api/books?page=2&per=2') }

        it 'receives HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'receives only one books' do
          expect(json_body['data'].size).to eq 1
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq '<http://www.example.com/api/books?page=1&per=2>; rel="first"'
        end
      end

      context "when sending invalid 'page' and 'per' parameters" do
        before { get('/api/books?page=fake&per=10') }

        it 'receives HTTP status 400' do
          expect(response).to have_http_status 400
        end
      end

      context "when sending invalid 'page' and 'per' parameters" do
        before { get '/api/books?page=fake&per=10'}

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
      context 'with valid column "id"' do
        it "sorts the books by 'id desc'" do
          get '/api/books?sort=id&dir=desc'
          expect(json_body['data'].first['id']).to eq books.last.id
          expect(json_body['data'].last['id']).to eq books.first.id
        end
      end

      context 'with invalid column name "fid"' do
        before { get '/api/books?sort=fid&dir=asc' }

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
      context "with valid filtering param 'q[title_cont]=Microscope'" do
        it "receives 'Ruby under a Microscope' back" do
          get "/api/books?q[title_cont]=Microscope"
          expect(json_body['data'].first['id']).to eq book_1.id
          expect(json_body['data'].size).to eq 1
        end
      end

      context "with invalid filtering param 'q[ftitle_cont]=Ruby'" do
        before { get '/api/books?q[ftitle_cont]=Ruby' }

        it 'gets 400 Bad Request back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'q[ftitle_cont]=Ruby' as an invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'q[ftitle_cont]=Ruby'
        end
      end
    end
  end
end
