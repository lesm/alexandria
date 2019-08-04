require 'rails_helper'

RSpec.describe UsersController, type: :request do
  let(:api_key) { create(:api_key) }
  let(:api_key_str) { "#{api_key.id}:#{api_key.key}" }

  let(:access_token) do
    create(:access_token, api_key: api_key, user: user)
  end
  let(:token) { access_token.generate_token }
  let(:token_str) { "#{user.id}:#{token}" }

  let(:headers) do
    { 'AUTHORIZATION' => "Alexandria-Token api_key=#{api_key_str}" }
  end

  let(:user) do
    create :user, given_name: 'Smith'
  end
  let(:user_dos) do
    create :user, given_name: 'Denizet'
  end
  let(:user_tres) do
    create :user, given_name: 'Denizet'
  end
  let(:users) { [user, user_dos, user_tres] }

  describe 'GET /api/users' do
    let(:headers) do
      {
        'AUTHORIZATION' =>
            "Alexandria-Token api_key=#{api_key_str}, access_token=#{token_str}"
      }
    end

    before { users }

    context 'default behaviour' do
      before do
        get '/api/users', headers: headers
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it "returns a json with the 'data' root key" do
        expect(json_body['data']).to_not be_nil
      end

      it 'returns all 2 users' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before do
          get '/api/users?fields=id,given_name,family_name', headers: headers
        end

        it 'gets users with only the id, given_name, family_name' do
          json_body['data'].each do |user|
            expect(user.keys).to eq %w(id given_name family_name)
          end
        end
      end

      context "without 'fields' parameter" do
        before { get '/api/users', headers: headers }

        it 'gets users with all the fields specified in the presenter' do
          json_body['data'].each do |user|
            expect(user.keys).to eq UserPresenter.build_attributes
          end
        end
      end

      context "with invalid fields name 'fid'" do
        before do
          get '/api/users?fields=fid,given_name', headers: headers
        end

        it 'gets 400 Bad Request back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get '/api/users?page=1&per=2', headers: headers }

        it 'receives HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'receives only two authors' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with the Link heade' do
          expect(response['Link'].split(', ').first).to eq '<http://www.example.com/api/users?page=2&per=2>; rel="next"'
        end
      end

      context 'when asking for the second page' do
        before { get '/api/users?page=2&per=2', headers: headers }

        it 'receives HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'receives only one user' do
          expect(json_body['data'].size).to eq 1
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq '<http://www.example.com/api/users?page=1&per=2>; rel="first"'
        end
      end

      context "when sending invalid 'page' and 'per' parameters" do
        before do
          get '/api/users?page=fake&per=10', headers: headers
        end

        it 'receives HTTP status 400' do
          expect(response).to have_http_status 400
        end

        it 'receives an error key' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'page=fake' as an invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'page=fake'
        end
      end
    end

    describe 'sorting' do
      context "with valid column 'id'" do
        it "sorts the users by 'id desc'" do
          get '/api/users?sort=id&dir=desc', headers: headers
          expect(json_body['data'].first['id']).to eq user_tres.id
          expect(json_body['data'].last['id']).to eq user.id
        end
      end

      context "with invalid column name 'fid'" do
        before do
          get '/api/users?sort=fid&dir=asc', headers: headers
        end

        it "gets '400 Bad Request' back" do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'sort=fid' as an invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'sort=fid'
        end
      end
    end

    describe 'filtering' do
      context "with valid filtering param q[given_name_cont]" do
        it "receives user 'Smith' back" do
          get "/api/users?q[given_name_cont]=Smith", headers: headers
          expect(json_body['data'].first['id']).to eq user.id
          expect(json_body['data'].size).to eq 1
        end
      end

      context "with invalid filtering param q[fgiven_name_cont]" do
        before do
          get '/api/users?q[fgiven_name_cont]=Smith', headers: headers
        end

        it 'gets "400 Bad Request" back' do
          expect(response).to have_http_status 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it "receives 'q[fgiven_name_cont]=Smith' as invalid param" do
          expect(json_body['error']['invalid_params']).to eq 'q[fgiven_name_cont]=Smith'
        end
      end
    end
  end

  describe 'GET /api/users/:id' do
    let(:headers) do
      {
        'AUTHORIZATION' =>
            "Alexandria-Token api_key=#{api_key_str}, access_token=#{token_str}"
      }
    end

    context 'with existing resource' do
      before { get "/api/users/#{user.id}", headers: headers }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'receives the user as JSON' do
        expected = { data: UserPresenter.new(user, {}).fields.embeds }
        expect(response.body).to eq expected.to_json
      end
    end

    context 'with nonexistent resource' do
      before { get '/api/users/89898989', headers: headers }

      it 'gets HTTP status 404' do
        expect(response).to have_http_status 404
      end

      it 'receives an error json message' do
        expect(json_body['error']).to_not be_nil
      end
    end
  end

  describe 'POST /api/users' do
    before do
      post '/api/users', params: { data: params }, headers: headers
    end

    context 'with valid params' do
      let(:params) { attributes_for :user }

      it 'gets HTTP status 201' do
        expect(response).to have_http_status 201
      end

      it 'receives the newly created resource' do
        expect(json_body['data']['given_name']).to eq params[:given_name]
      end

      it 'adds a record in the database' do
        expect(User.count).to eq 1
      end

      it 'gets the new resource location in the Location header' do
        expect(response.headers['Location']).to eq(
          "http://www.example.com/api/users/#{User.first.id}")
      end
    end

    context 'with invalid params' do
      let(:params) { attributes_for :user, given_name: '' }

      it 'gets HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'receives an error details' do
        expect(json_body['error']['invalid_params']).to eq(
          {"given_name" => ["can't be blank"] }
        )
      end

      it 'does not add a record in the database' do
        expect(User.count).to eq 0
      end
    end
  end

  describe 'PATCH /api/authors/:id' do
    let(:headers) do
      {
        'AUTHORIZATION' =>
            "Alexandria-Token api_key=#{api_key_str}, access_token=#{token_str}"
      }
    end

    before do
      patch "/api/users/#{user.id}", params: { data: params }, headers: headers
    end

    context 'with valid params' do
      let(:params) { { given_name: 'Pepito' } }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it "receives the updated resource" do
        expect(json_body['data']['given_name']).to eq "Pepito"
      end

      it 'updates the record in the database' do
        expect(User.first.given_name).to eq 'Pepito'
      end
    end

    context 'with invalid params' do
      let(:params) { { given_name: '' } }

      it 'gets HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'receives an error details' do
        expect(json_body['error']['invalid_params']).to eq(
          {"given_name" => ["can't be blank"]}
        )
      end

      it "doesn't update the record in the database" do
        expect(User.first.given_name).to eq 'Smith'
      end
    end
  end

  describe 'DELETE /api/users/:id' do
    let(:headers) do
      {
        'AUTHORIZATION' =>
        "Alexandria-Token api_key=#{api_key_str}, access_token=#{token_str}"
      }
    end

    context 'with existing resource' do
      let(:author) { create :user }
      before { delete "/api/users/#{user.id}", headers: headers }

      it 'gets HTTP status 204' do
        expect(response.status).to eq 204
      end

      it 'deletes the record from the database' do
        expect(User.count).to eq 0
      end
    end

    context 'with existing resource with dependencies' do
    end

    context 'with nonexistent resource' do
      it 'gets HTTP status 404' do
        delete '/api/users/898989', headers: headers
        expect(response).to have_http_status 404
      end
    end
  end
end
