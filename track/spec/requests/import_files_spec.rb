require 'rails_helper'

RSpec.describe "ImportFiles", type: :request do
  describe "GET /index" do
    let(:addresses_eth) { create(:addresses_eth) }
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
end
