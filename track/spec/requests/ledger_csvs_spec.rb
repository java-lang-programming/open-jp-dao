require 'rails_helper'

RSpec.describe LedgerCsvsController, type: :request do
  let(:addresses_eth) { create(:addresses_eth) }

  describe "GET /index" do
    context 'ログイン情報なし' do
      it "returns http success" do
        get ledger_csvs_path
        # TODO ここはログイン失敗画面に遷移していることを確認できるrspecに修正する
        expect(response.status).to eq(200)
      end
    end

    context 'when ログイン情報あり' do
      before do
        sign_in_as(address_record: addresses_eth)
      end

      # 画面遷移
      it "should be success." do
        get ledger_csvs_path
        expect(response.status).to eq(200)
        # 画面の内容を確認
        expect(response.body).to include 'CSVアップロード 一覧'
      end
    end
  end
end
