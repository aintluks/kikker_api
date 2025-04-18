require 'rails_helper'

RSpec.describe Api::V1::PostsController, type: :request do
  let(:user) { create(:user, login: 'testuser') }
  let(:valid_attributes) do
    {
      title: 'Test Post',
      body: 'This is a test post body',
      ip: '192.168.1.1',
      login: user.login
    }.to_json
  end

  let(:invalid_attributes) do
    {
      title: '',
      body: '',
      ip: '',
      login: ''
    }.to_json
  end

  let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  describe 'POST /api/v1/posts' do
    context 'with valid parameters' do
      it 'creates a new Post' do
        expect {
          post api_v1_posts_path, params: valid_attributes, headers: headers
        }.to change(Post, :count).by(1)
      end

      it 'does not create a new User when login exists' do
        user
        expect {
          post api_v1_posts_path, params: valid_attributes, headers: headers
        }.not_to change(User, :count)
      end

      it 'creates a new User when login does not exist' do
        expect {
          post api_v1_posts_path,
               params: { title: 'New', body: 'Content', ip: '1.1.1.1', login: 'newuser' }.to_json,
               headers: headers
        }.to change(User, :count).by(1)
      end

      it 'returns the created post with status :created' do
        post api_v1_posts_path, params: valid_attributes, headers: headers
        expect(response).to have_http_status(:created)
        expect(json_response['title']).to eq('Test Post')
        expect(json_response['body']).to eq('This is a test post body')
      end

      it 'associates the post with the correct user' do
        post api_v1_posts_path, params: valid_attributes, headers: headers
        expect(Post.last.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Post' do
        expect {
          post api_v1_posts_path, params: invalid_attributes, headers: headers
        }.not_to change(Post, :count)
      end

      it 'returns status :unprocessable_entity' do
        post api_v1_posts_path, params: invalid_attributes, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors when title and body are blank' do
        invalid_params = {
          title: '',
          body: '',
          ip: '',
          login: user.login
        }.to_json

        post api_v1_posts_path, params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response.keys).to include('errors')
        expect(json_response['errors']).to be_an(Array)
        expect(json_response['errors']).to include("Title can't be blank")
        expect(json_response['errors']).to include("Body can't be blank")
      end
    end

    context 'with non-json request' do
      it 'returns :not_acceptable status' do
        post api_v1_posts_path, params: { title: 'Test' }
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end
end
