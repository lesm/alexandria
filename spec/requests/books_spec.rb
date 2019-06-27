require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:books) { create_list :book, 3 }

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
    end
  end
end
