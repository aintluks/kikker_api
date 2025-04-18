require 'rails_helper'

RSpec.describe 'Api::V1::Ratings', type: :request do
  let(:user) { create(:user) }
  let(:post_record) { create(:post) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  describe 'POST /api/v1/ratings' do
    let(:valid_params) { { post_id: post_record.id, user_id: user.id, value: 4 } }

    context 'with valid parameters' do
      it 'enqueues RatePostJob' do
        expect {
          post api_v1_ratings_path, params: valid_params.to_json, headers: headers
        }.to have_enqueued_job(RatePostJob).with(post_record.id, user.id, 4)
      end

      it 'returns accepted with average rating' do
        allow(Rating).to receive(:average_rating).with(post_record.id).and_return(4.2)

        post api_v1_ratings_path, params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)['average_rating']).to eq(4.2)
      end
    end

    context 'with invalid rating value' do
      it 'returns unprocessable_entity' do
        allow(RatePostJob).to receive(:perform_later).and_raise(ArgumentError, 'value must be between 1 and 5')

        post api_v1_ratings_path,
             params: valid_params.merge(value: 6).to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].first).to match(/value must be between 1 and 5/)
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
        allow(RatePostJob).to receive(:perform_later).and_raise(StandardError, 'Queue down')
      end

      it 'returns internal_server' do
        post api_v1_ratings_path, params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
