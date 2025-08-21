require 'rails_helper'

RSpec.describe "Apis::Downloads", type: :request do
  describe "GET /api/downloads/:filename" do
    context "存在するファイルの場合" do
      it "ファイルをダウンロードできる" do
        get apis_download_path(filename: "dollar_yen_transactions_sample.csv")

        expect(response).to have_http_status(:ok)
        expect(response.header["Content-Disposition"]).to include("attachment")
        expect(response.header["Content-Type"]).to eq("text/csv")
        expect(response.body).to include("date,transaction_type,deposit_quantity,deposit_rate,withdrawal_quantity,exchange_en")
      end
    end

    context "存在しないファイルの場合" do
      it "404を返す" do
        get apis_download_path(filename: "not_found.csv")

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["error"]).to eq("File not Permit")
      end
    end
  end
end
