require 'rails_helper'

RSpec.describe "DollarYenTransactions", type: :request do
  describe "GET /index" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:session_sepolia) { create(:session_sepolia, address: addresses_eth) }

    context 'failure' do
      # セッションなし
      it "returns not_found_session.html.erb when session is not found." do
        get dollar_yen_transactions_path
        expect(response.body).to match('ログイン情報がありません。')
      end


      pending "chainGate connection is error #{__FILE__}"
      # # chainGateの接続に失敗
      # it "returns chain_gate_connection_refused.html.erb when chainGate connection is error." do

      # 	# サインイン
      # 	mock_apis_verify(body: {})
      #   get apis_sessions_nonce_path
      #   post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }

      #   mock_apis_verify_reset!
      #   get dollar_yen_transactions_path
      #   expect(response.body).to match('予期せぬエラーが発生しました')
      # end

      # chainGate verify APIの結果が失敗
      it "returns chain_gate_verify_failure.html.erb when verify was failure." do
        # サインイン
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }

        # verifyの2度目は失敗
        mock_apis_verify_custom(status: 400, body: {}, count: 1)
        get dollar_yen_transactions_path
        expect(response.body).to match('認証に失敗しました')
      end
    end

    context 'success' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      it "should get not data." do
        get dollar_yen_transactions_path
        expect(response.body).to include '全0件'
      end
    end
  end
end
