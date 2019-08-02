require 'rails_helper'

RSpec.describe 'Password Reset Flow', type: :request do
  let(:api_key) { create :api_key  }
  let(:token) do
    "Alexandria-Token api_key=#{api_key.id}:#{api_key.key}"
  end
  let(:headers) { { 'AUTHORIZATION' => token } }

  let(:user) { create :user }

  let(:create_params) do
    { email: user.email, reset_password_redirect_url: 'http://example.com' }
  end
  let(:update_params) { { password: 'new_password' } }

  it 'resets the password' do
    expect(user.authenticate('password')).to_not be false
    expect(user.reset_password_token).to be_nil

    #step 1
    post '/api/password_resets', params: { data: create_params },
      headers: headers
    expect(response).to have_http_status 204
    reset_token = user.reload.reset_password_token
    expect(ActionMailer::Base.deliveries.last.to_s).to match reset_token

    #step 2
    sbj = get "/api/password_resets/#{reset_token}"
    expect(sbj).to redirect_to("http://example.com?reset_token=#{reset_token}")

    #step 3
    patch "/api/password_resets/#{reset_token}",
      params: { data: update_params }, headers: headers
    expect(response).to have_http_status 204
    expect(user.reload.authenticate('new_password')).to_not be false
  end
end
