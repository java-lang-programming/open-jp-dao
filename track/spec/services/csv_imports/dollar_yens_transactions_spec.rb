require 'rails_helper'

RSpec.describe CsvImports::DollarYensTransactions, type: :feature do
  describe 'generate_dollar_yens_transactions' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_2) { create(:job_2) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:import_file) { create(:import_file, job: job_2, address: addresses_eth) }
    let(:import_file_second_time) { create(:import_file, job: job_2, address: addresses_eth) }
    let(:deposit_series_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_csv.csv" }
    let(:deposit_series_1_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_1.csv" }
    let(:deposit_series_2_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_2.csv" }

    context '最初の登録' do
      it 'should get list data.' do
        transaction_type1
        transaction_type2

        file = File.new(deposit_series_csv_path)
        import_file.file.attach(file)
        import_file.save

        ci = CsvImports::DollarYensTransactions.new(import_file: import_file)
        dollar_yens_transactions = ci.generate_dollar_yens_transactions

        expect(dollar_yens_transactions[:type]).to eq(CsvImports::DollarYensTransactions::GENERATE_KIND_INSERT)
        expect(dollar_yens_transactions[:dollar_yens_transactions].size).to eq(10)

        data1 = dollar_yens_transactions[:dollar_yens_transactions][0]
        expect(data1.date).to eq(Date.new(2020, 4, 1))
        expect(data1.transaction_type.name).to eq("HDV配当入金")
        expect(data1.deposit_quantity).to eq(BigDecimal("3.97"))
        expect(data1.deposit_rate).to eq(BigDecimal("106.59"))
        expect(data1.deposit_en).to eq(BigDecimal("423"))

        # TODO 9と10行目のデータを確認

        import_file.file.purge
      end
    end

    context '2度目の登録で歯抜けデータの追加' do
      it 'should get list data.' do
        transaction_type1
        transaction_type2

        # 一度目のcsv import
        file = File.new(deposit_series_1_csv_path)
        import_file.file.attach(file)
        import_file.save
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)


        # 　二度目のcsv import
        file2 = File.new(deposit_series_2_csv_path)
        import_file_second_time.file.attach(file2)
        import_file_second_time.save

        ci = CsvImports::DollarYensTransactions.new(import_file: import_file_second_time)
        dollar_yens_transactions = ci.generate_dollar_yens_transactions

        expect(dollar_yens_transactions[:type]).to eq(CsvImports::DollarYensTransactions::GENERATE_KIND_UPSERT)
        expect(dollar_yens_transactions[:dollar_yens_transactions].size).to eq(9)

        import_file.file.purge
        import_file_second_time.file.purge
      end
    end
  end
end
