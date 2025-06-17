require 'rails_helper'

RSpec.describe "Apis::DollarYens", type: :request do
  describe "Get /index" do
    let(:dollar_yen_20241218) { create(:dollar_yen_20241218) }
    let(:dollar_yen_20241219) { create(:dollar_yen_20241219) }

    context 'failure' do
      it "returns bad_request when params date is not found." do
        # データの実体化
        dollar_yen_20241219

        get apis_dollar_yens_path, params: { date: "20241218" }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "dateのドル円データは存在しません" } ] })
        expect(response).to have_http_status(:bad_request)
      end
    end


    context 'success' do
      it "returns ok when params is nothing." do
        # データの実体化
        dollar_yen_20241218
        dollar_yen_20241219

        get apis_dollar_yens_path
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({
          total: 2,
          dollar_yens: [
            {
              date: dollar_yen_20241218.formatted_date,
              dollar_yen_nakane: dollar_yen_20241218.formatted_dollar_yen_nakane
            },
            {
              date: dollar_yen_20241219.formatted_date,
              dollar_yen_nakane: dollar_yen_20241219.formatted_dollar_yen_nakane
            }
          ]
        })
        expect(response).to have_http_status(:ok)
      end

      it "returns ok when params date is found." do
        # データの実体化
        dollar_yen_20241218
        dollar_yen_20241219

        get apis_dollar_yens_path, params: { date: "20241218" }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({
          total: 1,
          dollar_yens: [
            {
              date: dollar_yen_20241218.formatted_date,
              dollar_yen_nakane: dollar_yen_20241218.formatted_dollar_yen_nakane
            }
          ]
        })
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "Post /csv import" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_1) { create(:job_1) }
    # let(:import_file) { create(:import_file, address: addresses_eth, job: job_1) }
    let(:failure_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_csv/failure.csv" }
    let(:success_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_csv/success.csv" }

    context 'no signin' do
      it "returns unauthorized." do
        post csv_import_apis_dollar_yens_path
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "権限がありません" } ] })
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'failure' do
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

      it "returns bad_request." do
        post csv_import_apis_dollar_yens_path
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "ファイルが存在しません" } ] })
        expect(response).to have_http_status(:bad_request)
      end

      it "returns bad_request." do
        post csv_import_apis_dollar_yens_path, params: { file: failure_csv_path }
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [
          { msg: [ "2行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ] },
          { msg: [ "3行目のdollar_yen_nakaneの値が不正です。数値、もしくは小数点付きの数値を入力してください" ] },
          { msg: [ "4行目のdateが入力されていません" ] },
          { msg: [ "5行目のdollar_yen_nakaneが入力されていません" ] },
          { msg: [ "6行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ] }
        ] })
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'success' do
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

      it "returns created." do
        job_1
        post csv_import_apis_dollar_yens_path, params: { file: fixture_file_upload(success_csv_path) }
        expect(response).to have_http_status(:created)
      end
    end
  end
end
