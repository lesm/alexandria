require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:books) { create_list :book, 3 }
  let(:json_body) { JSON.parse(response.body) }

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
  end
end
