require 'rails_helper'

RSpec.describe LedgerCsvImportJob, type: :job do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:ledger_2025_1_6_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/2025_1_6.csv" }
  let(:ledger_2025_1_6_errors_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/2025_1_6_errors.csv" }
  let(:job_3) { create(:job_3) }
  let(:ledger_item_1) { create(:ledger_item_1) }
  let(:ledger_item_2) { create(:ledger_item_2) }
  let(:ledger_item_3) { create(:ledger_item_3) }

  describe '失敗' do
    before do
      # データの実体化
      job_3
      ledger_item_1
      ledger_item_2
      ledger_item_3
    end

    it 'should be success.'  do
      ledger_csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: fixture_file_upload(ledger_2025_1_6_errors_path))
      LedgerCsvImportJob.perform_now(ledger_csv: ledger_csv)

      expect(addresses_eth.import_files.first.status).to eq('failure')
      expect(addresses_eth.ledgers.size).to eq(0)
      # 削除が呼ばれたことを確認
      # TODO エラーメッセージの保存
    end
  end

  describe '成功' do
    before do
      # データの実体化
      job_3
      ledger_item_1
      ledger_item_2
      ledger_item_3
    end

    it 'should be success.'  do
      ledger_csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: fixture_file_upload(ledger_2025_1_6_path))
      LedgerCsvImportJob.perform_now(ledger_csv: ledger_csv)

      expect(addresses_eth.import_files.first.status).to eq('completed')
      expect(addresses_eth.ledgers.size).to eq(25)
      # 削除が呼ばれたことを確認
      # expect(addresses_eth.import_files.first).to receive(:purge).and_call_original
      ledgers = addresses_eth.ledgers.order(:id)
      expect(ledgers[0].recorded_amount).to eq(1848)
      expect(ledgers[6].recorded_amount).to eq(1866)
      expect(ledgers[12].recorded_amount).to eq(2360)
      expect(ledgers[18].recorded_amount).to eq(3854)
      expect(ledgers[24].recorded_amount).to eq(9148)
    end
  end
end
