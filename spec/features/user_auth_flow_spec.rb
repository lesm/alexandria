require 'rails_helper'

RSpec.describe 'User Auth Flow', type: :request do
  def headers(user_id = nil, token = nil)
    api_key_str = "#{api_key.id}:#{api_key.key}"
    if user_id && token
      token_str = "#{user_id}:#{token}"
      { 'AUTHORIZATION' =>
          "Alexandria-Token api_key=#{api_key_str}, access_token=#{token_str}" }
    else
      { 'AUTHORIZATION' =>
          "Alexandria-Token api_key=#{api_key_str}" }
    end
  end

  let(:api_key) { create :api_key }
  let(:email) { 'john@gmail.com' }
  let(:password) { 'password' }
  let(:params) do
    {
      email: email,
      password: password,
      given_name: 'Johnny',
      family_name: 'Smith'
    }
  end

  it 'authenticate a new user' do
    #Step 1 - Create a User
    post '/api/users', params: { data: params }, headers: headers
    expect(response).to have_http_status 201
    id = json_body.dig("data", "id")

    #Step 2 - Try to update given name
    patch "/api/users/#{id}",
          params: { data: { given_name: 'John' } },
          headers: headers
    expect(response).to have_http_status 401

    #Step 3 - Login
    post '/api/access_tokens',
         params: { data: { email: email, password: 'password' } },
         headers: headers
    expect(response).to have_http_status 201
    expect(json_body.dig("data", "token")).to_not be_nil
    expect(json_body.dig("data", "user", "email")).to eq email
    token   = json_body.dig("data", "token")
    user_id = json_body.dig("data", "user", "id")

    #Step 4 - Update given_name
    patch "/api/users/#{id}",
          params: { data: { given_name: 'John' } },
          headers: headers(user_id, token)
    expect(response).to have_http_status 200
    expect(json_body.dig("data", "given_name")).to eq 'John'

    #Step 5 - Try to list all users
    get '/api/users', headers: headers(user_id, token)
    expect(response).to have_http_status 403

    #Step 6 - Logout
    delete '/api/access_tokens', headers: headers(user_id, token)
    expect(response).to have_http_status 204

    #Step 7 - Try to access user info with invalid token
    get "/api/users/#{id}", headers: headers(user_id, token)
    expect(response).to have_http_status 401
  end
end
