require 'rails_helper'

RSpec.describe 'Books', type: :request do
  describe 'GET /api/books' do
    it 'receives HTTP status 200' do
      get '/api/books'
      expect(response).to have_http_status(200)
    end
  end
end
