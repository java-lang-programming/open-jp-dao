require 'rails_helper'

RSpec.describe Files::RakutenCardImportCsvRow do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:master) { FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::RAKUTEN_CARD_YAML).master }
  let(:preload) {
    { address: addresses_eth, csv_ledgers_items: CsvLedgerItem.where(csv_id: Csv::ID_RAKUTEN_CARD).all }
  }
  # 通信費
  let(:ledger_item_1) {
    create(:ledger_item_1)
  }
  # 水道光熱費
  let(:ledger_item_2) {
    create(:ledger_item_2)
  }
  # 楽天カード
  let(:csv_2) {
    create(:csv_2)
  }
  let(:csv_ledger_item_4) {
    create(:csv_ledger_item_4, ledger_item: ledger_item_1, csv: csv_2)
  }
  let(:csv_ledger_item_5) {
    create(:csv_ledger_item_5, ledger_item: ledger_item_2, csv: csv_2)
  }
  let(:row_1) {
    [ '2024/11/24', 'ＮＴＴ東日本光コラボ回収　１１月分', '本人', '1回払い', "5643", "0", "5643", "5643", "0", "*" ]
  }
  let(:row_2) {
    [ '2024/11/24', 'ＥＮＥＯＳ　Ｐｏｗｅｒ（電気）', '本人', '1回払い', "11441", "0", "11441", "11441", "0", "*" ]
  }
  let(:row_5) {
    [ '2024/11/24', '支払い', '本人', '1回払い', "5643", "0", "5643", "5643", "0", "*" ]
  }
  let(:target_row) { row_1 }
  let(:instance) {
    described_class.new(master: master, row_num: 2, row: target_row, preload: preload)
  }

  before do
    csv_ledger_item_4
    csv_ledger_item_5
  end

  describe '#valid_errors' do
    context 'when エラーなし' do
      it 'should get {errors: []}.' do
       expect(instance.valid_errors).to eq({ errors: [] })
      end
    end
  end

  describe '#product_name_col_index' do
    it 'should get 1.' do
      expect(instance.product_name_col_index).to eq(1)
    end
  end

  describe '#total_amount_col_index' do
    it 'should get 6.' do
      expect(instance.total_amount_col_index).to eq(6)
    end
  end

  describe '#target?' do
    it 'should be true.' do
      expect(instance.target?).to be true
    end

    context 'without csv_ledger_item' do
      let(:target_row) { row_5 }
      it 'should be false.' do
        expect(instance.target?).to be false
      end
    end
  end

  describe 'find_csv_ledger_item_by_product_name' do
    context 'when 完全一致' do
      let(:target_row) { row_2 }

      it 'should get csv_ledger_item object.' do
        csv_ledger_item = instance.find_csv_ledger_item_by_product_name
        expect(csv_ledger_item).to eq(csv_ledger_item_5)
      end
    end

    context 'when 部分一致' do
      it 'should get csv_ledger_item object.' do
        csv_ledger_item = instance.find_csv_ledger_item_by_product_name
        expect(csv_ledger_item).to eq(csv_ledger_item_4)
      end
    end
  end

  describe '#calculate_face_value' do
    context 'when 支払い金額' do
      it 'should get face_value integer.' do
        face_value = instance.calculate_face_value
        expect(face_value).to eq(5643)
      end
    end
  end

  describe '#to_ledger' do
    context 'when 支払い金額' do
      it 'should get ledger.' do
        ledger = instance.to_ledger
        expect(ledger.date.to_date).to eq(Date.new(2024, 11, 24))
        expect(ledger.name).to eq('ＮＴＴ東日本光コラボ回収　１１月分')
        expect(ledger.ledger_item).to eq(ledger_item_1)
        expect(ledger.face_value).to eq(5643)
        expect(ledger.recorded_amount).to eq(3854)
      end
    end
  end

  describe 'to_upsert_all_ledger' do
    context 'upsert_allを実行するためのhashを取得する' do
      it 'should get hashed data.' do
        hash = instance.to_upsert_all_ledger
        expect(hash[:date]).to eq(Date.new(2024, 11, 24))
        expect(hash[:name]).to eq('ＮＴＴ東日本光コラボ回収　１１月分')
        expect(hash[:ledger_item_id]).to eq(ledger_item_1.id)
        expect(hash[:face_value]).to eq(5643)
        expect(hash[:proportion_rate]).to eq(csv_ledger_item_4.proportion_rate)
        expect(hash[:proportion_amount]).to eq(csv_ledger_item_4.proportion_amount)
        expect(hash[:recorded_amount]).to eq(3854)
        expect(hash[:address_id]).to eq(addresses_eth.id)
      end
    end
  end
end
