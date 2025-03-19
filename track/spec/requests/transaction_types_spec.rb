require 'rails_helper'

RSpec.describe "TransactionTypes", type: :request do
  describe "GET /index" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'success' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      it "should not get transaction_types." do
        get transaction_types_path
        body = response.body
        expect(response.status).to eq(200)
        expect(body).to include '取引種別が存在しません。'
      end

      it "should get transaction_types." do
        transaction_type1

        get transaction_types_path
        body = response.body
        expect(response.status).to eq(200)
        expect(body).to include "#{transaction_type1.name}"
      end
    end
  end

  describe "GET /new" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'success' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      it "should not get transaction_types." do
        get new_transaction_type_path
        body = response.body

        expect(response.status).to eq(200)
        expect(body).to include TransactionType::DEPOSIT_NAME
      end
    end
  end

  describe "post /create" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'success' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      it "should create transaction_types." do
        post transaction_types_path, params: { transaction_type: { name: "test", kind: 1 } }
        body = response.body

        expect(response.status).to eq(302)
        expect(addresses_eth.transaction_types.count).to eq(1)
      end
    end
  end

end
