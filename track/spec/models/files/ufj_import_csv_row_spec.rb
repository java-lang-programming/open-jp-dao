require 'rails_helper'

RSpec.describe Files::UfjImportCsvRow do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:master) { FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::UFJ_YAML).master }
  let(:preload) {
    { address: addresses_eth, csv_ledgers_items: CsvLedgerItem.where(csv_id: Csv::ID_UFJ).all }
  }
  let(:ledger_item_5) {
    create(:ledger_item_5)
  }
  let(:ledger_item_11) {
    create(:ledger_item_11)
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
  let(:row_1) {
    [ '2024/12/2', '税金', 'ネン２キ　シヨトク', '100,000', nil, "1,173,684" ]
  }
  let(:row_2) {
    [ '2024/12/2', '税金', 'コクミンネンキン', '17,320', nil, "1,000,000" ]
  }
  let(:row_3) {
    [ '2024/12/2', '口座振替３', 'コクミンケンコウホケン', '10,000', nil, "1,000,000" ]
  }
  let(:target_row) { row_2 }
  let(:instance) {
    described_class.new(master: master, row_num: 2, row: target_row, preload: preload)
  }

  before do
    csv_ledger_item_1
    csv_ledger_item_2
  end

  describe '#valid_errors' do
    context 'when エラーなし' do
      it 'should get {errors: []}.' do
       expect(instance.valid_errors).to eq({ errors: [] })
      end
    end
  end

  describe '#summary_col_index' do
    it 'should get 0.' do
      expect(instance.summary_col_index).to eq(1)
    end
  end

  describe '#summary_content_col_index' do
    it 'should get 1.' do
      expect(instance.summary_content_col_index).to eq(2)
    end
  end

  describe 'find_csv_ledger_item_by_summary_content' do
    context 'when 完全一致' do
      it 'should get csv_ledger_item object.' do
        csv_ledger_item = instance.find_csv_ledger_item_by_summary_content
        expect(csv_ledger_item).to eq(csv_ledger_item_2)
      end
    end

    context 'when 部分一致' do
      let(:target_row) { row_1 }

      it 'should get csv_ledger_item object.' do
        csv_ledger_item = instance.find_csv_ledger_item_by_summary_content
        expect(csv_ledger_item).to eq(csv_ledger_item_1)
      end
    end
  end

  # describe 'validate_error_of_csv_ledger_item' do
  #   context 'when 連携あり' do
  #     it 'should be nil.' do
  #       error = instance.validate_error_of_csv_ledger_item
  #       expect(error).to be nil
  #     end
  #   end
  #
  #   context 'when 連携データなし' do
  #     let(:target_row) { row_3 }
  #     it 'should be error msg.' do
  #       error = instance.validate_error_of_csv_ledger_item
  #       expect(error).to be nil
  #     end
  #   end
  # end

  describe '#calculate_face_value' do
    context 'when 支払い金額' do
      it 'should get face_value integer.' do
        face_value = instance.calculate_face_value
        expect(face_value).to eq(17320)
      end
    end
  end
  #
  # describe 'data_for_ledger' do
  #   context 'csvに記述されたnameのエラーを取得する' do
  #     it 'should get date.' do
  #       preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #       csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
  #       expect(csv_row.data_for_ledger(field: "date")).to eq(Date.new(2025, 1, 6))
  #     end
  #
  #     it 'should get name.' do
  #       preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #       csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
  #       expect(csv_row.data_for_ledger(field: "name")).to eq('MFクラウド')
  #     end
  #
  #     context 'when face_value' do
  #       # カンマなしface_value
  #       it 'should get face_value.' do
  #         preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #         csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
  #         expect(csv_row.data_for_ledger(field: "face_value")).to eq(1848)
  #       end
  #
  #       # カンマありface_value
  #       it 'should get face_value.' do
  #         preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #         csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1_comma_separated_face_value, preload: preload)
  #         expect(csv_row.data_for_ledger(field: "face_value")).to eq(1848)
  #       end
  #     end
  #
  #
  #     it 'should get proportion_rate.' do
  #       preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #       csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
  #       expect(csv_row.data_for_ledger(field: "proportion_rate")).to be nil
  #     end
  #
  #     it 'should get proportion_amount.' do
  #       preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #       csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
  #       expect(csv_row.data_for_ledger(field: "proportion_amount")).to be nil
  #     end
  #   end
  # end
  #
  describe '#to_ledger' do
    context 'Ledgerオブジェクトを取得する' do
      it 'should get ledger.' do
        ledger = instance.to_ledger
        expect(ledger.date.to_date).to eq(Date.new(2024, 12, 2))
        expect(ledger.name).to eq('コクミンネンキン')
        expect(ledger.ledger_item).to eq(ledger_item_5)
        expect(ledger.face_value).to eq(17320)
        expect(ledger.recorded_amount).to eq(17320)
      end
    end
  end
  #
  # describe 'to_upsert_all_ledger' do
  #   context 'upsert_allを実行するためのhashを取得する' do
  #     it 'should get hashed data.' do
  #       ledger_item_1
  #       preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #       csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
  #       hash = csv_row.to_upsert_all_ledger
  #       expect(hash[:date]).to eq(Date.new(2025, 1, 6))
  #       expect(hash[:name]).to eq('MFクラウド')
  #       expect(hash[:ledger_item_id]).to eq(ledger_item_1.id)
  #       expect(hash[:face_value]).to eq(1848)
  #       expect(hash[:proportion_rate]).to be nil
  #       expect(hash[:proportion_amount]).to be nil
  #       expect(hash[:recorded_amount]).to eq(1848)
  #       expect(hash[:address_id]).to eq(addresses_eth.id)
  #     end
  #   end
  # end
end
