require 'rails_helper'

RSpec.describe Api::V1::RatingsController, type: :request do
  let(:user) { create(:user) }
  let(:post_record) { create(:post) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  describe 'POST /api/v1/ratings' do
    let(:valid_params) { { post_id: post_record.id, user_id: user.id, value: 4 } }

    context 'with valid parameters' do
      it 'executes RatePostJob immediately' do
        allow(RatePostJob).to receive(:perform_now).and_return(true)
        
        post api_v1_ratings_path, params: valid_params.to_json, headers: headers
        
        expect(RatePostJob).to have_received(:perform_now)
          .with(post_record, user, 4)
      end

      it 'returns accepted status' do
        allow(RatePostJob).to receive(:perform_now).and_return(true)

        post api_v1_ratings_path, params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:accepted)
      end
    end

    context 'with invalid rating value' do
      it 'returns unprocessable_entity' do
        allow(RatePostJob).to receive(:perform_now)
          .with(post_record, user, 6)
          .and_raise(ArgumentError.new('value must be between 1 and 5'))
    
        post api_v1_ratings_path,
             params: valid_params.merge(value: 6).to_json,
             headers: headers
    
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].first).to match(/value must be between 1 and 5/i)
      end
    end

    context 'when post is not found' do
      it 'returns not_found' do
        post api_v1_ratings_path,
             params: valid_params.merge(post_id: -1).to_json,
             headers: headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors'].first).to match(/Couldn't find Post/)
      end
    end

    context 'when user is not found' do
      it 'returns not_found' do
        post api_v1_ratings_path,
             params: valid_params.merge(user_id: -1).to_json,
             headers: headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors'].first).to match(/Couldn't find User/)
      end
    end

    context 'when job fails unexpectedly' do
      before do
        allow(RatePostJob).to receive(:perform_now).and_raise(StandardError, 'Queue down')
      end

      it 'returns internal_server' do
        post api_v1_ratings_path, params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when user has already rated the post' do
      before do
        create(:rating, post: post_record, user: user)
      end
    
      it 'returns unprocessable_entity status' do
        post api_v1_ratings_path, params: valid_params.to_json, headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('User already rated this post')
      end
    
      it 'does not enqueue a job' do
        expect(RatePostJob).not_to receive(:perform_now)
        
        post api_v1_ratings_path, params: valid_params.to_json, headers: headers
      end
    
      it 'responds quickly without database calls' do
        expect(post_record.ratings).not_to receive(:exists?)
        
        post api_v1_ratings_path, params: valid_params.to_json, headers: headers
      end
    end
  end
end
