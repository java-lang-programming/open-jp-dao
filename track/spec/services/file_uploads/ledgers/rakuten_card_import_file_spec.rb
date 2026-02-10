require 'rails_helper'


RSpec.describe FileUploads::Ledgers::RakutenCardImportFile, type: :feature do
  let(:addresses_eth) { create(:addresses_eth) }
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
  let(:rakuten_card_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/rakuten_card/enavi202412.csv") }
  let(:import_file) {
    csv = FileUploads::Ledgers::RakutenCardFile.new(address: addresses_eth, file: rakuten_card_sample_path)
    csv.create_import_file
  }
  let(:instance) {
    described_class.new(import_file: import_file)
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

  describe '@csv_rows' do
    before do
      instance
    end

    it 'get 2 items.' do
      csv_rows = instance.csv_rows
      expect(csv_rows.size).to eq(2)
      expect(csv_rows[0].row[1]).to eq('ＮＴＴ東日本光コラボ回収　１２月分')
      expect(csv_rows[1].row[1]).to eq('ＥＮＥＯＳ　Ｐｏｗｅｒ（電気）')
    end
  end

  describe '#generate_ledgers' do
    context 'when upsert_all' do
      it "should be upsert_all data." do
        ledgers = instance.generate_ledgers
        expect(ledgers.size).to eq(2)
        expect(ledgers[0][:ledger_item_id]).to eq(ledger_item_1.id)
        expect(ledgers[0][:name]).to eq('ＮＴＴ東日本光コラボ回収　１２月分')
        expect(ledgers[0][:face_value]).to eq(5643)
        expect(ledgers[0][:proportion_rate]).to eq(csv_ledger_item_4.proportion_rate)
        expect(ledgers[0][:proportion_amount]).to eq(csv_ledger_item_4.proportion_amount)
        expect(ledgers[0][:recorded_amount]).to eq(3854)
        expect(ledgers[1][:ledger_item_id]).to eq(ledger_item_2.id)
        expect(ledgers[1][:name]).to eq('ＥＮＥＯＳ　Ｐｏｗｅｒ（電気）')
        expect(ledgers[1][:face_value]).to eq(9333)
        expect(ledgers[1][:proportion_rate]).to eq(csv_ledger_item_5.proportion_rate)
        expect(ledgers[1][:proportion_amount]).to eq(csv_ledger_item_5.proportion_amount)
        expect(ledgers[1][:recorded_amount]).to eq(1866)
      end
    end
  end
end
