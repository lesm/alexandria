require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'Client Authentication' do
    let(:headers) do
      { 'AUTHORIZATION' => "Alexandria-Token api_key=#{key}" }
    end

    before do
      get '/api/books', headers: headers
    end

    context 'with invalid authentication scheme' do
      context 'with invalid API Key' do
        let(:key) { 'fake' }

        it 'gets HTTP status 401 Unauthorized' do
          expect(response).to have_http_status 401
        end
      end

      context 'with disabled API Key' do
        let(:key) do
          create(:api_key).tap { |key| key.disable }.key
        end

        it 'gets HTTP status 401 Unauthorized' do
          expect(response).to have_http_status 401
        end
      end
    end

    context 'with valid API Key' do
      let(:key) { create(:api_key).key }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status 200
      end
    end
  end
end
