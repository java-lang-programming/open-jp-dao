require 'rails_helper'

RSpec.describe "Apis::Dollaryen::Downloads", type: :request do
  describe "GET /show" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }

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

    context 'csv_import' do
      it "returns http success" do
        dollar_yen_transaction1

        get apis_dollaryen_download_path("csv_import")
        expect(response).to have_http_status(:success)
        expect(response.headers["Content-Type"]).to include "text/csv"
        expect(response.body).to eq("date,transaction_type,deposit_quantity,deposit_rate,withdrawal_quantity,exchange_en\n2020/04/01,HDV配当入金,3.97,106.59,,")
      end
    end

    context 'export_import' do
      it "returns http success" do
        dollar_yen_transaction1

        get apis_dollaryen_download_path("csv_export")
        expect(response).to have_http_status(:success)
        expect(response.headers["Content-Type"]).to include "text/csv"
        expect(response.body).to eq("date,transaction_type,deposit_quantity,deposit_rate,deposit_en,withdrawal_quantity,withdrawal_rate,withdrawal_en,balance_quantity,balance_rate,balance_en\n2020/04/01,HDV配当入金,3.97,106.59,423,,,,3.97,106.5491183879093,423.0")
      end
    end
  end
end
