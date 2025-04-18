require 'rails_helper'

RSpec.describe 'GET /api/v1/posts/top_rated', type: :request do
  describe 'GET /posts/top_rated' do
    let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

    it 'returns the N posts with the highest average rating' do
      create(:post, title: 'Low').tap { |p| create_list(:rating, 2, post: p, value: 1) }
      create(:post, title: 'High').tap { |p| create_list(:rating, 2, post: p, value: 5) }

      get '/api/v1/posts/top_rated', params: { limit: 1 }, headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['title']).to eq('High')
      expect(json.first.keys).to contain_exactly('id', 'title', 'body')
    end
  end
end
