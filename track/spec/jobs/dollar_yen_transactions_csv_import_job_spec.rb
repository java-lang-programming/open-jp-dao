require 'rails_helper'

RSpec.describe DollarYenTransactionsCsvImportJob, type: :job do
  # 実行結果の確認
  describe 'perform' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_2) { create(:job_2) }
    let(:import_file) { create(:import_file, job: job_2, address: addresses_eth) }

    it 'should be status complete when job is success.' do
      DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
      result_import_file = ImportFile.find(import_file.id)
      expect(result_import_file.id).to eq(import_file.id)
      expect(result_import_file.status).to eq('completed')
    end
  end

  # キュー

  # https://qiita.com/necojackarc/items/b4a8ac682efeb1f62e74
  # リトライ
end
