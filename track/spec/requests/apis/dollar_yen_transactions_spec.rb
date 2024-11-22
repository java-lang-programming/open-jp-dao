require 'rails_helper'

RSpec.describe "Apis::DollarYenTransactions", type: :request do
  describe "Get /show" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }

    context "no data" do
      it "returns http not_found" do
        get apis_dollaryen_transaction_path(2)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "データが存在しません。" } ] })
        expect(response).to have_http_status(:not_found)
      end
    end

    context "no data" do
      it "returns http bad_request1" do
        get apis_dollaryen_transaction_path(dollar_yen_transaction1)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "Post /create" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction43) { create(:dollar_yen_transaction43, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context "date" do
      it "returns http bad_request1" do
        post apis_dollaryen_transactions_path, params: { transaction_type_id: 1, date: '20200401', deposit_rate: 106.59, deposit_quantity: 10.09 }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "dateの文字数が不正です。dataはyyyy-mm-ddの形式である必要があります。" } ] })
        expect(response).to have_http_status(:bad_request)
      end

      it "returns http bad_request2" do
        post apis_dollaryen_transactions_path, params: { transaction_type_id: 1, date: '2020/04/01', deposit_rate: 106.59, deposit_quantity: 10.09 }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "dateのフォーマットが不正です。dataはyyyy-mm-ddのハイフン形式である必要があります。" } ] })
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "transaction_type_id" do
      # transaction_type
      it "returns http bad_request3" do
        post apis_dollaryen_transactions_path, params: { transaction_type_id: 1, date: '2020-04-01' }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "transaction_typeが存在しません。" } ] })
        expect(response).to have_http_status(:bad_request)
      end
    end

    # address
    context "address" do
      # transaction_type
      it "returns http bad_request4" do
        post apis_dollaryen_transactions_path, params: { transaction_type_id: transaction_type1.id, date: '2020-04-01', address: 'asasad' }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "addressが存在しません。" } ] })
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "deposite" do
      context "model validate" do
        it "returns http bad_request4" do
          # transaction_type1の場合だけ
          post apis_dollaryen_transactions_path, params: { transaction_type_id: transaction_type1.id, date: '2020-04-01', address: addresses_eth.address }
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "Deposit rate is not a number" }, { msg: "Deposit quantity is not a number" } ] })
          expect(response).to have_http_status(:bad_request)
        end
      end

      it "returns http success" do
        post apis_dollaryen_transactions_path, params: { transaction_type_id: transaction_type1.id, date: '2020-04-01', deposit_rate: 106.59, deposit_quantity: 3.97, address: addresses_eth.address }
        expect(response).to have_http_status(:created)
      end
    end

    # withdrawal
    context "withdrawal" do
      context "model validate" do
        it "returns http bad_request when Withdrawal quantity is nil." do
          # transaction_type1の場合だけ
          post apis_dollaryen_transactions_path, params: { transaction_type_id: transaction_type5.id, date: '2020-04-01', address: addresses_eth.address }
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "Withdrawal quantity is not a number" }, { msg: "Exchange en is not a number" } ] })
          expect(response).to have_http_status(:bad_request)
        end

        it "returns http bad_request when exchange_en is nil." do
          # transaction_type1の場合だけ
          post apis_dollaryen_transactions_path, params: { transaction_type_id: transaction_type5.id, date: '2020-04-01', withdrawal_quantity: 88, address: addresses_eth.address }
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "Exchange en is not a number" } ] })
          expect(response).to have_http_status(:bad_request)
        end

        it "returns http bad_request when prev transactions not found." do
          expect {
            post apis_dollaryen_transactions_path, params: { transaction_type_id: transaction_type5.id, date: '2020-04-01', withdrawal_quantity: 88, exchange_en: 12918, address: addresses_eth.address }
          }.to raise_error(StandardError)
        end
      end

      it "returns http success" do
        # beforeデータ作成
        dollar_yen_transaction43
        post apis_dollaryen_transactions_path, params: { transaction_type_id: transaction_type5.id, date: '2024-02-01', withdrawal_quantity: 88, exchange_en: 12918, address: addresses_eth.address }
        expect(response).to have_http_status(:created)
      end

      # 　作成されたデータが意図通りかを確認
      it "created data" do
        # beforeデータ作成
        dollar_yen_transaction43
        post apis_dollaryen_transactions_path, params: { transaction_type_id: transaction_type5.id, date: '2024-02-01', withdrawal_quantity: 88, exchange_en: 12918, address: addresses_eth.address }
        data = DollarYenTransaction.where.not(id: dollar_yen_transaction43.id).first
        expect(response).to have_http_status(:created)
        expect(data.withdrawal_quantity).to eq(dollar_yen_transaction44.withdrawal_quantity)
        expect(data.exchange_en).to eq(dollar_yen_transaction44.exchange_en)
        expect(BigDecimal(data.exchange_difference).round).to eq(BigDecimal(dollar_yen_transaction44.exchange_difference).round)
        expect(BigDecimal(data.balance_rate).round(2)).to eq(BigDecimal(dollar_yen_transaction44.balance_rate).round(2))
        expect(BigDecimal(data.balance_quantity).round(2)).to eq(BigDecimal(dollar_yen_transaction44.balance_quantity).round(2))
        expect(BigDecimal(data.balance_en).round).to eq(BigDecimal(dollar_yen_transaction44.balance_en).round)
      end
    end
  end

  describe "Post /csv upload" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    # let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction43) { create(:dollar_yen_transaction43, transaction_type: transaction_type1, address: addresses_eth) }
    # let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }
    let(:error_deposit_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/error_deposit.csv" }

    it "returns bad_request." do
      # beforeデータ作成
      dollar_yen_transaction43
      post apis_dollaryen_transactions_csv_upload_path, params: { file: "", address_id: addresses_eth.id }
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json).to eq({ errors: [ { msg: "ファイルが存在しません" } ] })
      expect(response).to have_http_status(:bad_request)
    end

    it "returns bad_request." do
      # beforeデータ作成
      dollar_yen_transaction43
      post apis_dollaryen_transactions_csv_upload_path, params: { file: fixture_file_upload(error_deposit_csv_path), address_id: addresses_eth.id }
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json).to eq({ errors: [
        { msg: [ "2行目のdateが入力されていません" ] },
        { msg: [ "3行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください", "3行目のtransaction_typeが入力されていません" ] },
        { msg: [ "4行目のdeposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" ] },
        { msg: [ "5行目のdeposit_rateが入力されていません" ] },
        { msg: [ "6行目のdeposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" ] }
      ] })
      expect(response).to have_http_status(:bad_request)
    end
  end
end
