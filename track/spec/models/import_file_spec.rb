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
end
