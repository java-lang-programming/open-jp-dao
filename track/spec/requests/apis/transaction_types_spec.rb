require 'rails_helper'

RSpec.describe "Apis::TransactionTypes", type: :request do
  describe "GET /index" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'no sigin in' do
      # ログインなし
      it "returns unauthorized" do
        get apis_transaction_types_path
        json = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'sigin in' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      # データなし
      it "returns ok" do
        get apis_transaction_types_path
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({
          total: 0,
          transaction_types: []
        })
      end

      # データあり
      it "returns ok" do
        transaction_type1
        get apis_transaction_types_path
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({
          total: 1,
          transaction_types: [
            {
              id: transaction_type1.id,
              name: transaction_type1.name,
              kind: 1,
              kind_name: "預入"
            }
          ]
        })
      end
    end
  end
end
