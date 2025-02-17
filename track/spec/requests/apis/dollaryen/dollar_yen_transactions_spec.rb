require 'rails_helper'

RSpec.describe "Apis::DollarYenTransactions", type: :request do
  describe "Get /list" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }

    before do
      # sigin処理
      mock_apis_verify(body: {})
      get apis_sessions_nonce_path
      post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
    end

    context "no data" do
      it "returns http not_found" do
        get apis_dollaryen_transactions_path
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ total: 0, dollaryen_transactions: [] })
        expect(response).to have_http_status(:ok)
      end
    end

    context "find data" do
      it "returns http ok" do
        addresses_eth
        dollar_yen_transaction1
        dollar_yen_transaction2
        # dollar_yen_transaction3
        get apis_dollaryen_transactions_path, params: { address: addresses_eth.address, limit: 1, offset: 0 }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({
          total: 2,
          dollaryen_transactions: [
            {
              date: "2020/06/19",
              transaction_type_name: transaction_type1.name,
              deposit_en: 1140.0,
              deposit_quantity: 10.76,
              deposit_rate: 105.95,
              withdrawal_en: nil,
              withdrawal_quantity: nil,
              withdrawal_rate: nil,
              balance_quantity: 14.73,
              balance_rate: 106.10,
              balance_en: 1563
            }
          ]
        })
        expect(response).to have_http_status(:ok)
      end
    end
  end

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

    before do
      # sigin処理
      mock_apis_verify(body: {})
      get apis_sessions_nonce_path
      post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
    end

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
      let(:dollar_yen_transaction44) { build(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

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

  describe "Post /csv import" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { build(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { build(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction3) { build(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction43) { create(:dollar_yen_transaction43, transaction_type: transaction_type1, address: addresses_eth) }
    let(:job_2) { create(:job_2) }
    let(:error_deposit_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/error_deposit.csv" }
    let(:deposit_three_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_three_csv.csv" }

    before do
      # sigin処理
      mock_apis_verify(body: {})
      get apis_sessions_nonce_path
      post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
    end

    it "returns bad_request." do
      # beforeデータ作成
      dollar_yen_transaction43
      post apis_dollaryen_transactions_csv_import_path, params: { file: "", address: addresses_eth.address }
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json).to eq({ errors: [ { msg: "ファイルが存在しません" } ] })
      expect(response).to have_http_status(:bad_request)
    end

    it "returns bad_request." do
      # beforeデータ作成
      dollar_yen_transaction43
      post apis_dollaryen_transactions_csv_import_path, params: { file: fixture_file_upload(error_deposit_csv_path), address: addresses_eth.address }
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json).to eq({ errors: [
        { msg: [ "2行目のdateが入力されていません" ] },
        { msg: [ "3行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください", "3行目のtransaction_type_nameが入力されていません" ] },
        { msg: [ "4行目のdeposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" ] },
        { msg: [ "5行目のdeposit_rateが入力されていません" ] },
        { msg: [ "6行目のdeposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" ] }
      ] })
      expect(response).to have_http_status(:bad_request)
    end

    it "returns created." do
      transaction_type1
      job_2

      perform_enqueued_jobs do
        post apis_dollaryen_transactions_csv_import_path, params: { file: fixture_file_upload(deposit_three_csv_path), address: addresses_eth.address }
      end
      expect(response).to have_http_status(:created)

      dyts = DollarYenTransaction.where(address_id: addresses_eth.id)
      # 数の確認
      expect(dyts.size).to eq(3)

      data1 = dyts[0]
      data2 = dyts[1]
      data3 = dyts[2]

      # 1行目
      expect(data1.transaction_type).to eq(transaction_type1)
      expect(data1.date).to eq(dollar_yen_transaction1.date)
      expect(data1.deposit_rate).to eq(dollar_yen_transaction1.deposit_rate)
      expect(data1.deposit_quantity).to eq(dollar_yen_transaction1.deposit_quantity)
      expect(data1.deposit_en).to eq(dollar_yen_transaction1.deposit_en)
      expect(data1.balance_rate.truncate(6)).to eq(dollar_yen_transaction1.balance_rate.truncate(6))
      expect(data1.balance_quantity.truncate(6)).to eq(dollar_yen_transaction1.balance_quantity.truncate(6))
      expect(data1.balance_en.truncate(6)).to eq(dollar_yen_transaction1.balance_en.truncate(6))
      # 2行目
      expect(data2.transaction_type).to eq(transaction_type1)
      expect(data2.date).to eq(dollar_yen_transaction2.date)
      expect(data2.deposit_rate).to eq(dollar_yen_transaction2.deposit_rate)
      expect(data2.deposit_quantity).to eq(dollar_yen_transaction2.deposit_quantity)
      expect(data2.deposit_en).to eq(dollar_yen_transaction2.deposit_en)
      expect(data2.balance_rate.truncate(6)).to eq(dollar_yen_transaction2.balance_rate.truncate(6))
      expect(data2.balance_quantity.truncate(6)).to eq(dollar_yen_transaction2.balance_quantity.truncate(6))
      expect(data2.balance_en.truncate(6)).to eq(dollar_yen_transaction2.balance_en.truncate(6))
      # ３行目
      expect(data3.transaction_type).to eq(transaction_type1)
      expect(data3.date).to eq(dollar_yen_transaction3.date)
      expect(data3.deposit_rate).to eq(dollar_yen_transaction3.deposit_rate)
      expect(data3.deposit_quantity).to eq(dollar_yen_transaction3.deposit_quantity)
      expect(data3.deposit_en).to eq(dollar_yen_transaction3.deposit_en)
      expect(data3.balance_rate.truncate(6)).to eq(dollar_yen_transaction3.balance_rate.truncate(6))
      expect(data3.balance_quantity.truncate(6)).to eq(dollar_yen_transaction3.balance_quantity.truncate(6))
      expect(data3.balance_en.truncate(6)).to eq(dollar_yen_transaction3.balance_en.truncate(6))
    end
  end
end
