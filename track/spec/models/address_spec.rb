require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'generate_dollar_yen_transactions_csv_import_file' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_2) { create(:job_2) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:import_file) { create(:import_file, job: job_2, address: addresses_eth) }
    let(:deposit_series_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_csv.csv" }

    context 'csv_import_fileを作成' do
      # 1回import
      it 'should be create csv when DollarYenTransactionsCsvImportJob is performed.' do
        transaction_type1
        transaction_type2

        output_csv_file_path = "#{Rails.root}/tmp/storage/result.csv"

        file = File.new(deposit_series_csv_path)
        import_file.file.attach(file)
        import_file.save

        # 最初の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
        import_file.file.purge

        addresses_eth.generate_dollar_yen_transactions_csv_import_file(output_csv_file_path: output_csv_file_path)

        original_csvs = []
        CSV.foreach(deposit_series_csv_path) do |fg|
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
    let(:deposit_series_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_csv.csv" }
    let(:deposit_series_1_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_1.csv" }
    let(:deposit_series_2_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_2.csv" }
    let(:deposit_series_csv_export_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/export/deposit_series_csv_export.csv" }

    context 'csv_import_fileを作成' do
      # 1回import
      it 'should be create csv when DollarYenTransactionsCsvImportJob is performed.' do
        transaction_type1
        transaction_type2

        output_csv_file_path = "#{Rails.root}/tmp/storage/result.csv"

        file = File.new(deposit_series_csv_path)
        import_file.file.attach(file)
        import_file.save

        # 最初の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
        import_file.file.purge

        addresses_eth.generate_dollar_yen_transactions_csv_export_import_file(output_csv_file_path: output_csv_file_path)

        export_original_csvs = []
        CSV.foreach(deposit_series_csv_export_path) do |fg|
          export_original_csvs << fg
        end

        created_csvs = []
        CSV.foreach(output_csv_file_path) do |fg|
          created_csvs << fg
        end

        expect(export_original_csvs == created_csvs).to be true

        FileUtils.rm_rf(output_csv_file_path)
      end

      # 2回目import
      # 2回目は1回目で抜けていたデータを保管する
      it 'should be create csv when DollarYenTransactionsCsvImportJob is performed twice.' do
        transaction_type1
        transaction_type2

        file = File.new(deposit_series_1_csv_path)
        import_file.file.attach(file)
        import_file.save

        # 最初の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
        import_file.file.purge

        import_file2 = create(:import_file, job: job_2, address: addresses_eth)
        file2 = File.new(deposit_series_2_csv_path)
        import_file2.file.attach(file2)
        import_file2.save

        # 2回目の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file2.id)
        import_file2.file.purge

        output_csv_file_path = "#{Rails.root}/tmp/storage/result.csv"
        addresses_eth.generate_dollar_yen_transactions_csv_export_import_file(output_csv_file_path: output_csv_file_path)

        export_original_csvs = []
        CSV.foreach(deposit_series_csv_export_path) do |fg|
          export_original_csvs << fg
        end

        created_csvs = []
        CSV.foreach(output_csv_file_path) do |fg|
          created_csvs << fg
        end

        expect(export_original_csvs == created_csvs).to be true

        FileUtils.rm_rf(output_csv_file_path)
      end
    end
  end

  describe 'make_file_name' do
    let(:addresses_eth) { create(:addresses_eth) }

    context 'file_pathを作成' do
      it 'should be file_name.' do
        file_name = addresses_eth.make_file_name
        expect(file_name).to match(/#{addresses_eth.address}/)
      end
    end
  end
end
