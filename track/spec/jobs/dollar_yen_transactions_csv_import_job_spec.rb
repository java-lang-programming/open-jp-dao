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

  describe 'csv pattern' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_2) { create(:job_2) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:import_file) { create(:import_file, job: job_2, address: addresses_eth) }
    let(:import_file_2) { create(:import_file, job: job_2, address: addresses_eth) }
    let(:deposit_series_1_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_1.csv" }
    let(:deposit_series_2_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_2.csv" }

    it 'should be status complete when job is success.' do
      transaction_type1
      transaction_type2

      file = File.new(deposit_series_1_csv_path)
      import_file.file.attach(file)
      import_file.save

      # 最初の登録
      DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
      import_file.file.purge

      file2 = File.new(deposit_series_2_csv_path)
      import_file_2.file.attach(file2)
      import_file_2.save

      # 2度目の登録
      DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file_2.id)
      import_file_2.file.purge

      # TODO exportして、期待していいるデータかを比較する(excelで作る)

      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end
  end

  # キューの確認

  # https://qiita.com/necojackarc/items/b4a8ac682efeb1f62e74
  # リトライ


  # 値の確認
end
