require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'generate_dollar_yen_transactions_csv_import_file' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_2) { create(:job_2) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:import_file) { create(:import_file, job: job_2, address: addresses_eth) }
    let(:deposit_three_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_three_csv.csv" }

    context 'csv_import_fileを作成' do
      # 1回import
      it 'should be create csv when DollarYenTransactionsCsvImportJob is performed.' do
        transaction_type1
        transaction_type2

        output_csv_file_path = "#{Rails.root}/tmp/storage/result.csv"

        file = File.new(deposit_three_csv_path)
        import_file.file.attach(file)
        import_file.save

        # 最初の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
        import_file.file.purge

        addresses_eth.generate_dollar_yen_transactions_csv_import_file(output_csv_file_path: output_csv_file_path)

        original_csvs = []
        CSV.foreach(deposit_three_csv_path) do |fg|
          original_csvs << fg
        end

        created_csvs = []
        CSV.foreach(output_csv_file_path) do |fg|
          created_csvs << fg
        end

        expect(original_csvs == created_csvs).to be true

        import_file.file.purge
        FileUtils.rm_rf(output_csv_file_path)
      end
    end
  end

  describe 'generate_dollar_yen_transactions_csv_export_import_file' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_2) { create(:job_2) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:import_file) { create(:import_file, job: job_2, address: addresses_eth) }
    let(:deposit_three_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_three_csv.csv" }
    let(:deposit_three_csv_export_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/export/deposit_three_csv_export.csv" }

    context 'csv_import_fileを作成' do
      # 1回import
      it 'should be create csv when DollarYenTransactionsCsvImportJob is performed.' do
        transaction_type1
        transaction_type2

        output_csv_file_path = "#{Rails.root}/tmp/storage/result.csv"

        file = File.new(deposit_three_csv_path)
        import_file.file.attach(file)
        import_file.save

        # 最初の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
        import_file.file.purge

        addresses_eth.generate_dollar_yen_transactions_csv_export_import_file(output_csv_file_path: output_csv_file_path)

        export_original_csvs = []
        CSV.foreach(deposit_three_csv_export_path) do |fg|
          export_original_csvs << fg
        end

        created_csvs = []
        CSV.foreach(output_csv_file_path) do |fg|
          created_csvs << fg
        end

        expect(export_original_csvs == created_csvs).to be true

        import_file.file.purge
        FileUtils.rm_rf(output_csv_file_path)
      end
    end
  end
end
