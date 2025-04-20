require 'rails_helper'

RSpec.describe 'GET /api/v1/posts/top_rated', type: :request do
  describe 'GET /posts/top_rated' do
    let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

    before do
      create(:post, title: 'Low', body: '...')  .tap { |p| create_list(:rating, 2, post: p, value: 1) }
      create(:post, title: 'Mid', body: '...')  .tap { |p| create_list(:rating, 2, post: p, value: 3) }
      create(:post, title: 'High', body: '...') .tap { |p| create_list(:rating, 2, post: p, value: 5) }
    end

    it 'returns the top-rated posts in correct order with required fields' do
      get '/api/v1/posts/top_rated', params: { page: 1 }, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['posts'].size).to eq(3)
      expect(json['posts'].first['title']).to eq('High')
      expect(json['posts'].last['title']).to eq('Low')

      json['posts'].each do |post|
        expect(post.keys).to contain_exactly('id', 'title', 'body')
      end
    end

    it 'paginates the result and returns meta info' do
      get '/api/v1/posts/top_rated', params: { page: 1, per_page: 2 }, headers: headers

      json = JSON.parse(response.body)

      expect(json['posts'].size).to eq(2)
      expect(json['meta']).to include('current_page', 'next_page', 'prev_page', 'total_pages', 'total_count')
    end
  end
end
