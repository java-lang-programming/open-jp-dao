require 'rails_helper'

RSpec.describe ImportFile, type: :model do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:job_2) { create(:job_2) }
  let(:import_file) { create(:import_file, address: addresses_eth, job: job_2) }
  let(:deposit_and_withdrawal_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_and_withdrawal.csv" }

  describe 'save' do
    it 'should be true when attached?' do
      file = File.new(deposit_and_withdrawal_csv_path)
      import_file.file.attach(file)
      import_file.save
      expect(import_file.file.attached?).to be true
      # 削除
      import_file.file.purge
      expect(import_file.file.attached?).to be false
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end
  end


  describe 'purge' do
    it 'should be false when purge' do
      file = File.new(deposit_and_withdrawal_csv_path)
      import_file.file.attach(file)
      import_file.save
      import_file.file.purge
      expect(import_file.file.attached?).to be false
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end
  end

  describe 'make_csvs_dollar_yens_transactions' do
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }

    it 'should be false when purge' do
      transaction_type1
      transaction_type5

      file = File.new(deposit_and_withdrawal_csv_path)
      import_file.file.attach(file)
      import_file.save

      csvs = import_file.make_csvs_dollar_yens_transactions
      expect(csvs.size).to eq(4)

      import_file.file.purge
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end
  end

  describe 'include_past_dollar_yen_transaction?' do
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:deposit_and_withdrawal_2020_05_01_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_and_withdrawal_2020_05_01.csv" }
    let(:deposit_and_withdrawal_2020_06_19_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_and_withdrawal_2020_06_19.csv" }
    let(:deposit_and_withdrawal_2020_10_29_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_and_withdrawal_2020_10_29.csv" }

    # 　既存データがない時はfalse
    it 'should be false when registerd dollar_yen_transactions data not found.' do
      transaction_type1
      transaction_type5
      # dollar_yen_transaction2

      file = File.new(deposit_and_withdrawal_csv_path)
      import_file.file.attach(file)
      import_file.save

      csvs = import_file.make_csvs_dollar_yens_transactions

      past_dollar_yen_transaction = import_file.include_past_dollar_yen_transaction?(csvs: csvs)
      expect(past_dollar_yen_transaction).to be false

      import_file.file.purge
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end

    # 既存データ(過去データ)がある
    context 'registerd dollar_yen_transactions' do
      # 過去のデータのcsvデータがある時はtrue
      it 'should be true when csv includes past date.' do
        transaction_type1
        transaction_type5
        dollar_yen_transaction2

        file = File.new(deposit_and_withdrawal_2020_05_01_csv_path)
        import_file.file.attach(file)
        import_file.save

        csvs = import_file.make_csvs_dollar_yens_transactions

        past_dollar_yen_transaction = import_file.include_past_dollar_yen_transaction?(csvs: csvs)
        expect(past_dollar_yen_transaction).to be true

        import_file.file.purge
        FileUtils.rm_rf(ActiveStorage::Blob.service.root)
      end

      # 過去のデータのcsvデータがない時はfalse
      it 'should be false when csv not includes past date.' do
        transaction_type1
        transaction_type5
        dollar_yen_transaction2

        file = File.new(deposit_and_withdrawal_2020_10_29_csv_path)
        import_file.file.attach(file)
        import_file.save

        csvs = import_file.make_csvs_dollar_yens_transactions

        past_dollar_yen_transaction = import_file.include_past_dollar_yen_transaction?(csvs: csvs)
        expect(past_dollar_yen_transaction).to be false

        import_file.file.purge
        FileUtils.rm_rf(ActiveStorage::Blob.service.root)
      end

      # 同じ日のデータのcsvデータの時はfalse
      it 'should be false when csv is same date.' do
        transaction_type1
        transaction_type5
        dollar_yen_transaction2

        file = File.new(deposit_and_withdrawal_2020_06_19_csv_path)
        import_file.file.attach(file)
        import_file.save

        csvs = import_file.make_csvs_dollar_yens_transactions

        past_dollar_yen_transaction = import_file.include_past_dollar_yen_transaction?(csvs: csvs)
        expect(past_dollar_yen_transaction).to be false

        import_file.file.purge
        FileUtils.rm_rf(ActiveStorage::Blob.service.root)
      end
    end
  end

  describe 'get_oldest_date' do
    it 'should be oldtest date' do
      file = File.new(deposit_and_withdrawal_csv_path)
      import_file.file.attach(file)
      import_file.save

      csvs = import_file.make_csvs_dollar_yens_transactions
      oldest_date = import_file.get_oldest_date(csvs: csvs)

      expect(oldest_date).to eq(Date.new(2020, 4, 1))

      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end
  end

  describe '#target_screen' do
    it 'should get job2 screen name.' do
      expect(import_file.target_screen).to eq('ドル円外貨預金元帳')
    end
  end

  describe '#set_target_path' do
    let(:target_path) { 'localhost' }

    it 'should be oldtest date' do
      import_file.set_target_path(target_path: target_path)
      expect(import_file.get_target_path).to eq(target_path)
    end
  end
end
