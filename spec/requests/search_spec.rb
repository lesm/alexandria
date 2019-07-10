require 'rails_helper'

RSpec.describe SearchController, type: :request do
  let(:key) { create(:api_key).key }
  let(:headers) do
    { 'AUTHORIZATION' => "Alexandria-Token api_key=#{key}" }
  end

  let(:book_1) { create :book, title: 'Ruby Microscope' }
  let(:book_2) { create :book, title: 'Ruby on Rails Tutorial' }
  let(:author) { create :author, given_name: 'Sam Ruby' }
  let(:book_3) do
    create :book, title: 'Agile Web Development', author: author
  end
  let(:books) { [book_1, book_2, book_3] }

  describe 'GET /api/search/:text' do
    before { books }

    context "with text = 'ruby'" do
      before { get '/api/search/ruby', headers: headers }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it "receives the book_1 back" do
        expect(json_body['data'][0]['searchable_id']).to eq book_1.id
        expect(json_body['data'][0]['searchable_type']).to eq 'Book'
      end

      it "receives the book_2 back" do
        expect(json_body['data'][1]['searchable_id']).to eq book_2.id
        expect(json_body['data'][1]['searchable_type']).to eq 'Book'
      end

      it "receives the book_3 back" do
        expect(json_body['data'][2]['searchable_id']).to eq book_3.author.id
        expect(json_body['data'][2]['searchable_type']).to eq 'Author'
      end
    end
  end
end
