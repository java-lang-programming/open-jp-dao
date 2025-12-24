require 'rails_helper'

# DollarYenTransactionCsvでもいいな
RSpec.describe DollarYenTransactions::CsvCoordinationsController, type: :request do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
  let(:external_service) { create(:external_service) }

  describe "GET /index" do
    before do
      sign_in_as(address_record: addresses_eth)
    end

    it "should be get 未連携." do
       get dollar_yen_transactions_csv_coordinations_path
       # ステータスコードの検証
       expect(response).to have_http_status(200)
       body = response.body
       expect(body).to include '未連携'
    end

    context 'when 連携' do
      let(:external_service_transaction_type) {
        create(
          :external_service_transaction_type,
          external_service: external_service,
          transaction_type: transaction_type5
        )
      }

      before do
        external_service_transaction_type
      end

      it "should be get 連携済." do
        get dollar_yen_transactions_csv_coordinations_path
        expect(response).to have_http_status(200)
        body = response.body
        expect(body).to include '連携済'
      end
    end
  end

  describe "GET /show" do
    let(:id) { 1 }
    before do
      sign_in_as(address_record: addresses_eth)
    end

    # 存在しないExternalService
    it "should be get 404." do
      get dollar_yen_transactions_csv_coordination_path(id: id)
      expect(response).to have_http_status(404)
    end

    context 'when 連携データなし' do
      before do
        external_service
      end

      it "should be get 200." do
        get dollar_yen_transactions_csv_coordination_path(id: external_service.id)
        expect(response).to have_http_status(200)
      end
    end

    context 'when 連携データあり' do
      let(:external_service_transaction_type) {
        create(
          :external_service_transaction_type,
          external_service: external_service,
          transaction_type: transaction_type5
        )
      }

      before do
        external_service_transaction_type
      end

      it "should be get 200." do
        get dollar_yen_transactions_csv_coordination_path(id: external_service.id)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET /new" do
    let(:id) { 1 }
    let(:params) {  }
    before do
      sign_in_as(address_record: addresses_eth)
    end

    # 存在しないExternalService
    it "should be get 404." do
      get dollar_yen_transactions_csv_coordination_path(id: id)
      expect(response).to have_http_status(404)
    end

    context 'when 連携データなし' do
      before do
        external_service
        transaction_type5
      end

      it "should be get 200." do
        get dollar_yen_transactions_csv_coordination_path(id: external_service.id)
        expect(response).to have_http_status(200)
      end
    end

    context 'when 連携データあり' do
      let(:external_service_transaction_type) {
        create(
          :external_service_transaction_type,
          external_service: external_service,
          transaction_type: transaction_type5
        )
      }

      before do
        external_service_transaction_type
      end

      it "should be get 200." do
        get dollar_yen_transactions_csv_coordination_path(id: external_service.id)
        expect(response).to have_http_status(200)
      end
    end
  end

  # describe "post /create" do
  #
  # end
  #
  # describe "delete /destroy" do
  #
  # end
end
