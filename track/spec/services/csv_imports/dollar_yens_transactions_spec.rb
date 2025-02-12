require 'rails_helper'

RSpec.describe CsvImports::DollarYensTransactions, type: :feature do
  describe 'files_dollar_yen_transaction_csvs' do
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
        csvs = ci.files_dollar_yen_transaction_csvs

        assert_csv(csvs: csvs)
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


        #　二度目のcsv import
        file2 = File.new(deposit_series_2_csv_path)
        import_file_second_time.file.attach(file2)
        import_file_second_time.save

        ci = CsvImports::DollarYensTransactions.new(import_file: import_file_second_time)
        csvs = ci.files_dollar_yen_transaction_csvs        

        assert_csv(csvs: csvs)

        import_file.file.purge
        import_file_second_time.file.purge
      end
    end
  end

  def assert_csv(csvs: csvs)
    expect(csvs.length).to eq(10)

    csv0 = csvs[0]
    expect(csv0.date).to eq("2020/04/01")
    expect(csv0.transaction_type_name).to eq("HDV配当入金")
    expect(csv0.deposit_quantity).to eq("3.97")
    expect(csv0.deposit_rate).to eq("106.59")
    expect(csv0.withdrawal_quantity).to be nil
    expect(csv0.exchange_en).to be nil

    csv1 = csvs[1]
    puts csv1.inspect
    expect(csv1.date).to eq("2020/06/19")
    expect(csv1.transaction_type_name).to eq("HDV配当入金")
    expect(csv1.deposit_quantity).to eq("10.76")
    expect(csv1.deposit_rate).to eq("105.95")
    expect(csv1.withdrawal_quantity).to be nil
    expect(csv1.exchange_en).to be nil

    csv2 = csvs[2]
    expect(csv2.date).to eq("2020/09/29")
    expect(csv2.transaction_type_name).to eq("HDV配当入金")
    expect(csv2.deposit_quantity).to eq("14.73")
    expect(csv2.deposit_rate).to eq("104.35")
    expect(csv2.withdrawal_quantity).to be nil
    expect(csv2.exchange_en).to be nil
  end
end
