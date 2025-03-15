require 'rails_helper'

RSpec.describe "DollarYenTransactions", type: :request do
  describe "GET /index" do
    let(:addresses_eth) { create(:addresses_eth) }

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
      # it "returns chain_gate_verify_failure.html.erb when verify was failure." do
      #   # サインイン
      #   mock_apis_verify(body: {})
      #   get apis_sessions_nonce_path
      #   post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }

      #   # verifyの2度目は失敗
      #   mock_apis_verify_custom(status: 400, body: {}, count: 1)
      #   get dollar_yen_transactions_path
      #   expect(response.body).to match('認証に失敗しました')
      # end
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
        body = response.body
        expect(body).to include 'ドル円外貨預金元帳'
        expect(response.body).to include '全0件'
      end
    end
  end

  describe "GET /new" do
    let(:addresses_eth) { create(:addresses_eth) }

    context 'success' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      it "should get not data when date is not found." do
        get new_dollar_yen_transaction_path
        body = response.body
        expect(body).to include 'ドル円外貨預金元帳 新規作成'
        expect(body).to include addresses_eth.address
      end
    end
  end

  describe "POST /create_confirmation" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    # let(:dollar_yen_transaction1_same_day) { create(:dollar_yen_transaction1, transaction_type: transaction_type2, address: addresses_eth) }

    context 'success' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      # validareエラー
      it "should get not data when date is not found." do
        post create_confirmation_dollar_yen_transactions_path, params: { dollar_yen_transaction: { transaction_type: "1", deposit_quantity: "100.10", deposit_rate: "130.32" } }
      end

      # 初回データの作成
      it "should get not data when date is not found." do
        transaction_type1
        post create_confirmation_dollar_yen_transactions_path, params: { dollar_yen_transaction: { date: "2022-01-01", transaction_type: "1", deposit_quantity: "100.10", deposit_rate: "130.32" } }
        expect(addresses_eth.dollar_yen_transactions.count).to eq(1)
      end

      context '確認画面へ' do
        # 追加データで50件以下の既存データを更新する
        it "should get update message when 再計算 date is found." do
          dollar_yen_transaction1
          dollar_yen_transaction3

          # dollar_yen_transaction2を追加
          post create_confirmation_dollar_yen_transactions_path, params: { dollar_yen_transaction: { date: "2020-06-19", transaction_type: "1", deposit_quantity: "10.76", deposit_rate: "105.95" } }

          expect(response.body).to include '取引データが1件あります'
        end

        # 追加データで50件を超える既存データを更新する
        it "should get not data when 再計算 date is 50件を超える." do
          dollar_yen_transaction2
          base_date = dollar_yen_transaction2.date
          50.times do
            base_date = base_date.tomorrow
            post create_confirmation_dollar_yen_transactions_path, params: { dollar_yen_transaction: { date: base_date.strftime("%Y-%m-%d"), transaction_type: "1", deposit_quantity: "10.76", deposit_rate: "105.95" } }
          end

          # dollar_yen_transaction2を追加
          post create_confirmation_dollar_yen_transactions_path, params: { dollar_yen_transaction: { date: "2020-06-18", transaction_type: "1", deposit_quantity: "10.76", deposit_rate: "105.95" } }

          expect(response.body).to include '2020-06-18以降の取引データが51件あります'
        end
      end




      #
    end
  end
end
