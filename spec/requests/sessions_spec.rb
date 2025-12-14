require 'rails_helper'

RSpec.describe "トークンでの認証", type: :request do
  let(:user) { create(:user) }

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end

  context '有効なトークンでリクエストした場合' do
    it "200が返る" do
      get root_path, headers: auth_headers(user.api_token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq({ message: "疎通確認OK" }.to_json)
    end
  end

  context '無効なトークンでリクエストした場合' do
    it "403が返る" do
      get root_path, headers: auth_headers('invalid_api_token')
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to eq({ error: "認証できませんでした" }.to_json)
    end
  end
end
