require 'rails_helper'

RSpec.describe TaxReturns::Calculation do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:ledger_2025_1_6_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/2025_1_6.csv") }
  let(:job_3) { create(:job_3) }
  let(:ledger_item_1) { create(:ledger_item_1) }
  let(:ledger_item_2) { create(:ledger_item_2) }
  let(:ledger_item_3) { create(:ledger_item_3) }

  describe 'execute' do
    before do
      # データの実体化
      job_3
      ledger_item_1
      ledger_item_2
      ledger_item_3
      # 　データ作成
      ledger_file = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_2025_1_6_path)
      import_file = ledger_file.create_import_file
      LedgerCsvImportJob.perform_now(import_file_id: import_file.id)
    end

    after do
      # テスト用フォルダごとファイル削除
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end

    context '作成.' do
      it 'should get expense and costs.' do
        service = TaxReturns::Calculation.new(address: addresses_eth, year: 2025)
        result = service.execute
        expect(result).to eq({
           communication_expense: 50364,
           utility_costs: 14852,
           supplies_expense: 9148
        })
      end
    end
  end
end
