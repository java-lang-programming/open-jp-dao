require 'rails_helper'

RSpec.describe "Ledgers", type: :request do
  # describe "GET /index" do
  #   it "returns http success" do
  #     get "/ledger/index"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  describe "GET /csv_upload_new" do
    let(:addresses_eth) { create(:addresses_eth) }

    context 'ログイン情報なし' do
      it "returns http success" do
        get csv_upload_new_ledgers_path
        # TODO ここはログイン失敗画面に遷移していることを確認できるrspecに修正する
        expect(response.status).to eq(200)
      end
    end

    context 'ログイン情報あり' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        mock_apis_ens(
          status: 200,
          body: { ens_name: "test.eth" }
        )
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      # 画面遷移
      it "should be success." do
        get csv_upload_new_ledgers_path
        expect(response.status).to eq(200)
        # 画面の内容を確認
        expect(response.body).to include 'アップロード開始'
      end
    end
  end
end
