require 'rails_helper'

RSpec.describe "Apis::Dollaryen::ForeigneExchangeGains", type: :request do
  describe "GET /index" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction43) { create(:dollar_yen_transaction43, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context 'no sigin in' do
      it "returns bad_request when no sigined." do
        get apis_dollaryen_foreigne_exchange_gain_index_path
        json = JSON.parse(response.body, symbolize_names: true)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'sigined address' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      context "error" do
        it "returns bad_request when no year query." do
          get apis_dollaryen_foreigne_exchange_gain_index_path, params: { year: Date.today.year }
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "withdrawalの取引種別が存在しません" } ] })
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "success" do
        it "returns ok when transaction data is not found." do
          transaction_type2
          transaction_type5
          dollar_yen_transaction43
          dollar_yen_transaction44
          get apis_dollaryen_foreigne_exchange_gain_index_path, params: { year: Date.today.year }
          json = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(:ok)

          year = Date.today.year
          start_date = "#{year}-01-01"
          end_date = "#{year}-12-31"
          expect(json[:date][:start_date]).to eq(start_date)
          expect(json[:date][:end_date]).to eq(end_date)
          expect(json[:data][:total]).to eq(0)
          expect(json[:data][:dollaryen_transactions]).to eq([])
        end

        it "returns ok when transaction data is found." do
          transaction_type2
          transaction_type5
          year = Date.today.year
          dollar_yen_transaction43.date = Date.new(year, 1, 1)
          dollar_yen_transaction43.save!
          dollar_yen_transaction44.date = Date.new(year, 12, 31)
          dollar_yen_transaction44.save!

          get apis_dollaryen_foreigne_exchange_gain_index_path, params: { year: year }
          json = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(:ok)

          start_date = "#{year}-01-01"
          end_date = "#{year}-12-31"
          expect(json[:date][:start_date]).to eq(start_date)
          expect(json[:date][:end_date]).to eq(end_date)
          expect(json[:data][:total]).to eq(1)
          expect(json[:foreign_exchange_gain]).to eq(857.0)
        end
      end
    end
  end
end
