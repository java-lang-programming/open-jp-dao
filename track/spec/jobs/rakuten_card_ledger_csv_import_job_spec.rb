require 'rails_helper'

RSpec.describe RakutenCardLedgerCsvImportJob, type: :job do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:rakuten_card_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/rakuten_card/enavi202412.csv") }
  let(:job_5) { create(:job_5) }
  # 通信費
  let(:ledger_item_1) {
    create(:ledger_item_1)
  }
  # 水道光熱費
  let(:ledger_item_2) {
    create(:ledger_item_2)
  }
  let(:csv_2) {
    create(:csv_2)
  }
  let(:csv_ledger_item_4) {
    create(:csv_ledger_item_4, ledger_item: ledger_item_1, csv: csv_2)
  }
  let(:csv_ledger_item_5) {
    create(:csv_ledger_item_5, ledger_item: ledger_item_2, csv: csv_2)
  }
  let(:csv_2) {
    create(:csv_2)
  }
  let(:import_file) {
    csv = FileUploads::Ledgers::RakutenCardFile.new(address: addresses_eth, file: rakuten_card_sample_path)
    csv.create_import_file
  }

  before do
    job_5
    csv_ledger_item_4
    csv_ledger_item_5
  end

  after do
    # テスト用フォルダごとファイル削除
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end

  describe '成功' do
    it 'should be success.'  do
      described_class.perform_now(import_file_id: import_file.id)

      expect(addresses_eth.import_files.first.status).to eq('completed')
      # データが2件作成されていること
      expect(addresses_eth.ledgers.size).to eq(2)

      ledgers = addresses_eth.ledgers.order(:id)
      # 通信費
      ledger_item_tsushin = ledgers.where(ledger_item_id: ledger_item_1.id).first
      expect(ledger_item_tsushin.recorded_amount).to eq(3854)
      # 水道光熱費
      ledger_item_eneos = ledgers.where(ledger_item_id: ledger_item_2.id).first
      expect(ledger_item_eneos.recorded_amount).to eq(1866)
    end

    context '2回実行' do
      let(:import_file_2nd) {
        csv = FileUploads::Ledgers::RakutenCardFile.new(address: addresses_eth, file: rakuten_card_sample_path)
        csv.create_import_file
      }

      it 'should be success.'  do
        # 1回目(新規)
        described_class.perform_now(import_file_id: import_file.id)

        expect(addresses_eth.import_files.size).to eq(1)
        expect(addresses_eth.import_files.first.status).to eq('completed')
        expect(addresses_eth.ledgers.size).to eq(2)

        # ２回目(更新)
        described_class.perform_now(import_file_id: import_file_2nd.id)

        expect(addresses_eth.import_files.size).to eq(2)
        expect(addresses_eth.import_files.first.status).to eq('completed')
        # 　1回目と同じデータなので件数は変わらない
        expect(addresses_eth.ledgers.size).to eq(2)
      end
    end

    context 'エラーが発生した場合' do
      let(:import_file_3rd) {
        csv = FileUploads::Ledgers::RakutenCardFile.new(address: addresses_eth, file: rakuten_card_sample_path)
        csv.create_import_file
      }

      before do
        # upsert_all が呼ばれた時にエラーを投げるよう設定
        allow(Ledger).to receive(:upsert_all).and_raise(ActiveRecord::RecordNotUnique)
      end

      it 'ステータスを failure に変更し、Rails.error.report を呼び出すこと' do
        described_class.perform_now(import_file_id: import_file_3rd.id)

        expect(addresses_eth.import_files.where(id: import_file_3rd.id).first.status).to eq 'failure'
      end
    end
  end

  describe 'キューの指定' do
    it 'csvキューにジョブが入ること' do
      expect {
        described_class.perform_later(import_file_id: import_file.id)
      }.to have_enqueued_job.on_queue('csv')
    end
  end
end
