require 'rails_helper'

RSpec.describe "ImportFiles", type: :request do
  let(:addresses_eth) { create(:addresses_eth) }
  describe "GET /index" do
    let(:job_2) { create(:job_2) }
    let(:import_file) { create(:import_file, job: job_2, address: addresses_eth) }

    context 'failure' do
      # セッションなし
      it "returns not_found_session.html.erb when session is not found." do
        get import_files_path
        expect(response.body).to match('ログイン情報がありません。')
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

      it "should get not data." do
        get import_files_path
        expect(response.body).to include '全0件'
      end

      it "should get not data." do
        # 実体化
        import_file

        get import_files_path
        body = response.body
        expect(body).to include '全1件'
        expect(body).to include import_file.job.name
        expect(body).to include import_file.status_on_screen
      end
    end
  end

  describe "GET /result" do
    let(:job_3) { create(:job_3) }
    let(:import_file_completed) { create(:import_file, job: job_3, address: addresses_eth, status: :completed) }
    let(:import_file_failure) {
      create(:import_file_failure, job: job_3, address: addresses_eth)
    }
    let(:import_file_error) {
      create(:import_file_error, import_file: import_file_failure, error_json: { errors: [ { row: 2, col: 1, attribute: "date", value: "2025-01-06", message: "dateのフォーマットが不正です。yyyy/mm/dd形式で入力してください。" }, { row: 4, col: 1, attribute: "date", value: "2025/04/32", message: "dateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください。" }, { row: 6, col: 1, attribute: "date", value: nil, message: "dateが未記入です。dateは必須入力です。" } ] }.to_json)
    }

    context 'failure' do
      # セッションなし
      it "returns not_found_session.html.erb when session is not found." do
        get result_import_file_path(import_file_failure)
        expect(response.body).to match('ログイン情報がありません。')
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

      context '自分のimportfileデータがない' do
        # 　失敗データあり
        it "returns http success" do
          get result_import_file_path(4444)
          expect(response).to have_http_status(:not_found)
        end
      end

      context '自分のimportfileデータがある' do
        # 失敗データ
        it "returns http success when import_file_failure" do
          # データ作成
          import_file_failure
          import_file_error

          get result_import_file_path(import_file_failure)
          expect(response).to have_http_status(:ok)
        end

        # 失敗データ以外
        it "returns http success when import_file_completed" do
          # データ作成
          import_file_completed

          get result_import_file_path(import_file_completed)
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
