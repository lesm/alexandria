require 'rails_helper'

RSpec.describe PasswordResetsController, type: :request do
  let(:api_key) { create :api_key }
  let(:token) do
    "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}"
  end
  let(:headers) { { 'AUTHORIZATION' => token } }

  let(:user) { create :user }

  describe 'POST /api/password_resets' do
    context 'with valid params' do
      let(:params) do
        {
          data: {
            email: user.email,
            reset_password_redirect_url: 'http://example.com'
          }
        }
      end

      before do
        post '/api/password_resets', params: params, headers: headers
      end

      it 'returns HTTP status 204' do
        expect(response).to have_http_status 204
      end

      it 'sends the reset password email' do
        expect(ActionMailer::Base.deliveries.last.subject).to eq(
          'Reset your password'
        )
      end

      it 'adds the reset password attributes to "user"' do
        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
        updated = user.reload
        expect(updated.reset_password_token).to_not be_nil
        expect(updated.reset_password_sent_at).to_not be_nil
        expect(updated.reset_password_redirect_url).to eq(
          'http://example.com')
      end
    end

    context 'with invalid params' do
      let(:params) { { data: { email: user.email } } }
      before do
        post '/api/password_resets', params: params, headers: headers
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end
    end

    context 'with nonexisting user' do
      let(:params) { { data: { email: 'fake@mail.mx' } } }
      before do
        post '/api/password_resets', params: params, headers: headers
      end

      it 'returns HTTP status 404' do
        expect(response).to have_http_status 404
      end
    end
  end
end
