require 'rails_helper'

RSpec.describe "Ledgers", type: :request do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:job_3) { create(:job_3) }
  let(:ledger_item_1) { create(:ledger_item_1) }
  let(:ledger_item_2) { create(:ledger_item_2) }
  let(:ledger_item_3) { create(:ledger_item_3) }
  let(:ledger_csv_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample.csv") }

  describe "GET /index" do
    context 'ログイン情報あり' do
      before do
        # データの実体化
        job_3
        ledger_item_1
        ledger_item_2
        ledger_item_3
        # sigin処理
        mock_apis_verify(body: {})
        mock_apis_ens(
          status: 200,
          body: { ens_name: "test.eth" }
        )
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      after do
        # テスト用フォルダごとファイル削除
        FileUtils.rm_rf(ActiveStorage::Blob.service.root)
      end

      it "returns http success" do
        # データ作成
        csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_csv_sample_path)
        import_file = csv.create_import_file
        LedgerCsvImportJob.perform_now(import_file_id: import_file.id)

        get ledgers_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /csv_upload_new" do
    context 'ログイン情報なし' do
      it "returns http success" do
        get csv_upload_new_ledgers_path
        # TODO ここはログイン失敗画面に遷移していることを確認できるrspecに修正する
        expect(response.status).to eq(200)
      end
    end

    context 'ログイン情報あり' do
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

      # 画面遷移
      it "should be success." do
        get csv_upload_new_ledgers_path
        expect(response.status).to eq(200)
        # 画面の内容を確認
        expect(response.body).to include 'アップロード開始'
      end
    end
  end

  describe "post /csv_upload" do
    context 'ログイン情報あり' do
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

      after do
        # テスト用フォルダごとファイル削除
        FileUtils.rm_rf(ActiveStorage::Blob.service.root)
      end

      # 画面遷移
      it "should be success." do
        job_3
        post csv_upload_ledgers_path, params: { import_file: { file: ledger_csv_sample_path } }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
