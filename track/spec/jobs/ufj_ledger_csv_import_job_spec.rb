require 'rails_helper'

RSpec.describe UfjLedgerCsvImportJob, type: :job do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:ufj_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ufj/decode_4615179_20250127092225.csv") }
  let(:job_4) { create(:job_4) }
  # コクミンネンキン
  let(:ledger_item_5) {
    create(:ledger_item_5)
  }
  # コクミンケンコウホケン
  let(:ledger_item_6) {
    create(:ledger_item_6)
  }
  # カクテイキヨシユツカケキ
  let(:ledger_item_7) {
    create(:ledger_item_7)
  }
  # シヨウキボキヨウサイ
  let(:ledger_item_8) {
    create(:ledger_item_8)
  }
  # ２キ　シヨトク
  let(:ledger_item_11) {
    create(:ledger_item_11)
  }
  # カ）アイ−ガイシャ
  let(:ledger_item_13) {
    create(:ledger_item_13)
  }
  let(:csv_1) {
    create(:csv_1)
  }
  let(:csv_ledger_item_1) {
    create(:csv_ledger_item_1, ledger_item: ledger_item_11, csv: csv_1)
  }
  let(:csv_ledger_item_2) {
    create(:csv_ledger_item_2, ledger_item: ledger_item_5, csv: csv_1)
  }
  let(:csv_ledger_item_3) {
    create(:csv_ledger_item_3, ledger_item: ledger_item_13, csv: csv_1)
  }
  let(:import_file) {
    csv = FileUploads::Ledgers::UfjFile.new(address: addresses_eth, file: ufj_sample_path)
    csv.create_import_file
  }

  before do
    job_4
    ledger_item_5
    ledger_item_6
    ledger_item_7
    ledger_item_8
    ledger_item_11
    ledger_item_13
    # csv連携データ
    csv_ledger_item_1
    csv_ledger_item_2
    csv_ledger_item_3
  end

  after do
    # テスト用フォルダごとファイル削除
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end

  # describe '失敗' do
  #   before do
  #     # データの実体化
  #     job_4
  #     ledger_item_1
  #     ledger_item_2
  #     ledger_item_3
  #   end
  #
  #   it 'should be success.'  do
  #     csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_2025_1_6_errors_path)
  #     import_file = csv.create_import_file
  #     LedgerCsvImportJob.perform_now(import_file_id: import_file.id)
  #
  #     expect(addresses_eth.import_files.first.status).to eq('failure')
  #     expect(addresses_eth.ledgers.size).to eq(0)
  #   end
  # end

  describe '成功' do
    it 'should be success.'  do
      UfjLedgerCsvImportJob.perform_now(import_file_id: import_file.id)

      expect(addresses_eth.import_files.first.status).to eq('completed')
      expect(addresses_eth.ledgers.size).to eq(3)
      # TODO 削除が呼ばれたことを確認
      # expect(addresses_eth.import_files.first).to receive(:purge).and_call_original
      ledgers = addresses_eth.ledgers.order(:id)
      # ２キ　シヨトク
      ledger_item_2ki_shotoku = ledgers.where(ledger_item_id: ledger_item_11.id).first
      expect(ledger_item_2ki_shotoku.recorded_amount).to eq(100001)
      # コクミンネンキン
      ledger_item_kokuminnenkin = ledgers.where(ledger_item_id: ledger_item_5.id).first
      expect(ledger_item_kokuminnenkin.recorded_amount).to eq(17320)
      # カ）アイ−ガイシャ
      ledger_item_kokuminnenkin = ledgers.where(ledger_item_id: ledger_item_13.id).first
      expect(ledger_item_kokuminnenkin.recorded_amount).to eq(100000)
    end

    context '2回実行' do
      let(:import_file_2nd) {
        csv = FileUploads::Ledgers::UfjFile.new(address: addresses_eth, file: ufj_sample_path)
        csv.create_import_file
      }

      it 'should be success.'  do
        # 1回目(新規)
        UfjLedgerCsvImportJob.perform_now(import_file_id: import_file.id)

        expect(addresses_eth.import_files.size).to eq(1)
        expect(addresses_eth.import_files.first.status).to eq('completed')
        expect(addresses_eth.ledgers.size).to eq(3)

        # ２回目(更新)
        UfjLedgerCsvImportJob.perform_now(import_file_id: import_file_2nd.id)

        expect(addresses_eth.import_files.size).to eq(2)
        expect(addresses_eth.import_files.first.status).to eq('completed')
        expect(addresses_eth.ledgers.size).to eq(3)
      end
    end
  end
end
