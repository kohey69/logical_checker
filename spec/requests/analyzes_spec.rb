require 'rails_helper'

RSpec.describe "テキスト解析API", type: :request do
  let(:user) { create(:user) }
  let(:valid_text) { "田中さんが昨日、会議室でプロジェクトの進捗を報告した" }
  let(:mock_response) do
    {
      who: { present: true, confidence: 0.9, value: "田中さん", note: "主語として明示されている" },
      when: { present: true, confidence: 0.9, value: "昨日", note: "時間が明示されている" },
      what: { present: true, confidence: 0.9, value: "進捗を報告した", note: "行動が明示されている" },
      where: { present: true, confidence: 0.8, value: "会議室", note: "場所が明示されている" },
      why: { present: false, confidence: 0.7, value: nil, note: "目的や理由は明示されていない" },
      how: { present: false, confidence: 0.6, value: nil, note: "手段や方法は明示されていない" }
    }
  end

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end

  before do
    allow_any_instance_of(TextAnalyzer).to receive(:call).and_return(mock_response)
  end

  describe "POST /analyzes" do
    context "有効なトークンでリクエストした場合" do
      context "textパラメータがある場合" do
        it "200と解析結果が返る" do
          post analyzes_path, params: { text: valid_text }, headers: auth_headers(user.api_token), as: :json

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:who][:present]).to be true
          expect(json[:who][:value]).to eq "田中さん"
        end
      end

      context "textパラメータがない場合" do
        it "400とエラーメッセージが返る" do
          post analyzes_path, params: {}, headers: auth_headers(user.api_token), as: :json

          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:error]).to eq "text パラメータは必須です"
        end
      end

      context "textパラメータが空文字の場合" do
        it "400とエラーメッセージが返る" do
          post analyzes_path, params: { text: "" }, headers: auth_headers(user.api_token), as: :json

          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:error]).to eq "text パラメータは必須です"
        end
      end
    end

    context "無効なトークンでリクエストした場合" do
      it "401が返る" do
        post analyzes_path, params: { text: valid_text }, headers: auth_headers("invalid_token"), as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
