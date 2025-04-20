require 'rails_helper'

RSpec.describe 'GET /api/v1/posts/ip_authors', type: :request do
  let(:user) { create(:user, login: 'testuser') }

  let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  describe 'GET /api/v1/posts/ip_authors' do
    before do
      create(:post, ip: '10.0.0.1', user: user)
      create(:post, ip: '10.0.0.2', user: user)
      create(:post, ip: '10.0.0.1', user: create(:user, login: 'another_user'))
    end

    it 'returns grouped IPs with associated logins' do
      get ip_authors_api_v1_posts_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data']).to be_an(Array)
      expect(json_response['meta']).to be_present

      grouped = json_response['data'].map { |item| item['ip'] }
      expect(grouped).to include('10.0.0.1', '10.0.0.2')
    end
  end
end
