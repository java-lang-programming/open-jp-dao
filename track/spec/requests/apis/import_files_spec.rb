require 'rails_helper'

RSpec.describe "Apis::ImportFiles", type: :request do
  describe "GET /index" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_1) { create(:job_1) }
    let(:job_2) { create(:job_2) }
    let(:import_file) { create(:import_file, address: addresses_eth, job: job_1) }
    let(:import_file_in_progress) { create(:import_file_in_progress, address: addresses_eth, job: job_2) }
    let(:import_file_completed) { create(:import_file_completed, address: addresses_eth, job: job_1) }
    let(:import_file_failure) { create(:import_file_failure, address: addresses_eth, job: job_2) }

    before do
      # sigin処理
      mock_apis_verify(body: {})
      get apis_sessions_nonce_path
      post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
    end

    it "returns http success" do
      get apis_import_files_index_path
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json).to eq({ total: 0, import_files: [] })
    end

    it "returns four responses" do
      import_file
      import_file_in_progress
      import_file_completed
      import_file_failure

      get apis_import_files_index_path
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:total]).to eq(4)
      expect(json[:import_files][0][:status]).to eq("failure")
      expect(json[:import_files][1][:status]).to eq("completed")
      expect(json[:import_files][2][:status]).to eq("in_progress")
      expect(json[:import_files][3][:status]).to eq("ready")
    end
  end
end
