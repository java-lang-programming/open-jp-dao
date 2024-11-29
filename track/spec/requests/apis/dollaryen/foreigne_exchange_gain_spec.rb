require 'rails_helper'

RSpec.describe "Apis::Dollaryen::ForeigneExchangeGains", type: :request do
  describe "GET /index" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }

    context "error" do
      it "returns bad_request when no year query." do
        get apis_dollaryen_foreigne_exchange_gain_index_path, params: { address: addresses_eth.address, year: Date.today.year }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "withdrawalの取引種別が存在しません" } ] })
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "success" do
      it "returns ok." do
        transaction_type5
        get apis_dollaryen_foreigne_exchange_gain_index_path, params: { address: addresses_eth.address, year: Date.today.year }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
