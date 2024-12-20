require 'rails_helper'

RSpec.describe "Apis::DollarYens", type: :request do
  describe "Post /csv import" do
    let(:failure_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_csv/failure.csv" }
    let(:success_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_csv/success.csv" }

    context 'failure' do
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
      it "returns created." do
        post csv_import_apis_dollar_yens_path, params: { file: success_csv_path }
        expect(response).to have_http_status(:created)
      end
    end
  end
end
