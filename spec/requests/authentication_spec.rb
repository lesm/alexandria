require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'Client Authentication' do
    let(:token) do
      "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}"
    end
    let(:headers) { { 'AUTHORIZATION' => token } }

    before do
      get '/api/books', headers: headers
    end

    context 'with invalid authentication scheme' do
      context 'with invalid API Key' do
        let(:api_key) { OpenStruct.new(id: 1, key: 'fake') }

        it 'gets HTTP status 401 Unauthorized' do
          expect(response).to have_http_status 401
        end
      end

      context 'with disabled API Key' do
        let(:api_key) do
          create(:api_key).tap { |key| key.disable }
        end

        it 'gets HTTP status 401 Unauthorized' do
          expect(response).to have_http_status 401
        end
      end
    end

    context 'with valid API Key' do
      let(:api_key) { create(:api_key) }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status 200
      end
    end
  end
end
