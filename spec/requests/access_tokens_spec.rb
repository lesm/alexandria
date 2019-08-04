require 'rails_helper'

RSpec.describe 'Access Tokens', type: :request do
  let(:api_key) { create :api_key  }
  let(:token) do
    "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}"
  end
  let(:headers) { { 'AUTHORIZATION' => token } }

  let(:user) { create :user }

  describe 'POST /api/access_tokens' do
    context 'with valid API key' do
      before do
        post '/api/access_tokens/', params: params, headers: headers
      end

      context 'with existing user' do
        context 'with valid password' do
          let(:params) do
            { data: { email: user.email, password: 'password' } }
          end

          it 'gets HTTP status 201 created' do
            expect(response).to have_http_status 201
          end

          it 'receives an access_token' do
            expect(json_body['data']['token']).to_not be_nil
          end

          it 'receives the user embedded' do
            expect(json_body['data']['user']['id']).to eq user.id
          end
        end
      end

      context 'with nonexisting user' do
        let(:params) do
          { data: { email: 'unknow', password: 'fake' } }
        end

        it 'gets an HTTP status 404 Not Found' do
          expect(response).to have_http_status 404
        end
      end
    end

    context 'with invalid api_key' do
      it 'returns HTTP status 401 Forbidden' do
        post '/api/access_tokens', params: {}, headers: {}
        expect(response).to have_http_status 401
      end
    end
  end

  describe 'DELETE /api/access_tokens' do
    context 'with valid API key' do
      let(:api_key) { create :api_key  }
      let(:api_key_str) { "#{api_key.id}:#{api_key.key}" }

      before { delete '/api/access_tokens', headers: headers }

      context 'with valid access token' do
        let(:access_token) do
          create(:access_token, api_key: api_key, user: user)
        end
        let(:token) { access_token.generate_token }
        let(:token_str) { "#{user.id}:#{token}" }

        let(:headers) do
          {
            'AUTHORIZATION' =>
              "Alexandria-Token api_key=#{api_key_str}, access_token=#{token_str}"
          }
        end

        it 'returns "204 No Content" status code' do
          expect(response).to have_http_status 204
        end

        it 'destroys the access token' do
          expect(user.reload.access_tokens.size).to eq 0
        end
      end

      context 'with invalid access token' do
        let(:headers) do
          {
            'HTTP_AUTHORIZATION' =>
              "Alexandria-Token api_key=#{api_key_str}, access_token=1:fake"
          }
        end

        it 'returns "401" status code' do
          expect(response).to have_http_status 401
        end
      end
    end

    context 'with invalid API key' do
      it 'returns HTTP status 401' do
        delete '/api/access_tokens/', params: {}
        expect(response).to have_http_status 401
      end
    end
  end
end
