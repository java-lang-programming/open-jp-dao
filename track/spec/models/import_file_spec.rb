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
end
