require 'rails_helper'


RSpec.describe LedgerCsvIntegrationsController, type: :request do
  let(:addresses_eth) { create(:addresses_eth) }

  describe "GET /ufj_csv_upload_new" do
    context 'ログイン情報なし' do
      it "returns http success" do
        get ufj_csv_upload_new_ledger_csv_integrations_path
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
        get ufj_csv_upload_new_ledger_csv_integrations_path
        expect(response.status).to eq(200)
        # 画面の内容を確認
        expect(response.body).to include 'アップロード開始'
      end
    end
  end

  describe "POST /ufj_csv_upload" do
    let(:ufj_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ufj/decode_4615179_20250127092225.csv") }
    let(:ledger_csv_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample.csv") }
    let(:job_4) { create(:job_4) }
    let(:params) { { import_file: { file: ufj_sample_path } } }

    before do
      job_4
      sign_in_as(address_record: addresses_eth)
    end

    after do
      # テスト用フォルダごとファイル削除
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end

    context "when ファイルが選択されていない場合" do
      let(:params) { { import_file: { file: nil } } }

      it "should be errors." do
        post ufj_csv_upload_ledger_csv_integrations_path, params: params
        expect(response).to have_http_status(:unprocessable_content)
        # 画面の内容を確認
        expect(response.body).to include 'uploadファイルが存在しません。ファイルを選択ボタンからファイルを選択してください'
      end
    end

    context "when headerがエラーの場合" do
      let(:params) { { import_file: { file: ledger_csv_sample_path } } }

      it "should be errors." do
        post ufj_csv_upload_ledger_csv_integrations_path, params: params
        expect(response).to have_http_status(:unprocessable_content)
        # 画面に表示されるはずの内容を確認
        expect(response.body).to include 'ヘッダの属性名が不正です。正しい属性名は日付です'
      end
    end

    # 画面遷移
    it "should be success." do
      post ufj_csv_upload_ledger_csv_integrations_path, params: params
      expect(response).to have_http_status(:ok)
    end
  end
end
