require 'rails_helper'

RSpec.describe UserConfirmationsController, type: :request do
  let(:api_key) { create(:api_key) }
  let(:token) do
    "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}"
  end
  let(:headers) { { 'AUTHORIZATION' => token } }

  describe 'GET /api/user_confirmations/:confirmation_token' do
    describe 'with existing token' do
      context 'with confirmation redirect url' do
        subject do
          get "/api/user_confirmations/#{user.confirmation_token}", headers: headers
        end

        let(:user) { create :user, :confirmation_redirect_url }

        it 'redirects to https://www.google.com' do
          expect(subject).to redirect_to('https://www.google.com')
        end
      end

      context 'without confirmation redirect url' do
        let(:user) { create :user, :confirmation_no_redirect_url }
        before do
          get "/api/user_confirmations/#{user.confirmation_token}", headers: headers
        end

        it 'returns "HTTP status 200"' do
          expect(response).to have_http_status 200
        end

        it 'renders "You are now confirmed!"' do
          expect(response.body).to eq "You are now confirmed!"
        end
      end
    end

    context 'with noexisting token' do
      before do
        get "/api/user_confirmations/fake", headers: headers
      end

      it 'returns "HTTP status 404"' do
        expect(response).to have_http_status 404
      end

      it 'renders "Token not found"' do
        expect(response.body).to eq "Token not found"
      end
    end
  end
end
