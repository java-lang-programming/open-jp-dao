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
  let(:csv_1) {
    create(:csv_1)
  }
  let(:csv_ledger_item_2) {
    create(:csv_ledger_item_2, ledger_item: ledger_item_5, csv: csv_1,)
  }

  let(:instance) {
    described_class.new(master: master, row_num: 1, row: row_2, preload: preload)
  }
  let(:row_1) {
    [ '2024/12/2', '税金', '６ネン２キ　シヨトク', '273,400', nil, "1,173,684" ]
  }
  let(:row_2) {
    [ '2024/12/2', '税金', 'コクミンネンキン', '17,320', nil, "1,000,000" ]
  }

  before do
    csv_ledger_item_2
  end

  describe '#valid_errors' do
    context 'when エラーなし' do
      it 'should get {errors: []}.' do
        expect(instance.valid_errors).to eq({errors: []})
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

      # it 'should get nil.' do
      #   ledger_item_1
      #   preload = { address: addresses_eth, ledger_items: LedgerItem.all }
      #   row = [ '2025/01/06', '通信', 'MFクラウド', '1848', nil, nil ]
      #   csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row, preload: preload)
      #   ledger_item = csv_row.find_ledger_item_by_name
      #   expect(ledger_item).to be nil
      # end
    end
  end
  #
  # describe 'validate_error_of_name' do
  #   context 'csvに記述されたnameのエラーを取得する' do
  #     it 'should no error.' do
  #       ledger_item_1
  #       preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #       csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
  #       validate_error = csv_row.validate_error_of_name
  #       expect(validate_error).to be nil
  #     end
  #
  #     it 'should get error object.' do
  #       ledger_item_1
  #       preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #       row = [ '2025/01/06', '通信', 'MFクラウド', '1848', nil, nil ]
  #       csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row, preload: preload)
  #       validate_error = csv_row.validate_error_of_name
  #       expect(validate_error).to eq({
  #                                      row: 1,
  #                                      col: 2,
  #                                      attribute: 'ledger_item',
  #                                      value: '通信',
  #                                      message: "通信はledger_itemに存在しません"
  #                                    })
  #     end
  #   end
  # end
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
  # describe 'to_ledger' do
  #   context 'Ledgerオブジェクトを取得する' do
  #     it 'should get ledger.' do
  #       ledger_item_1
  #       preload = { address: addresses_eth, ledger_items: LedgerItem.all }
  #       csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
  #       ledger = csv_row.to_ledger
  #       expect(ledger.date.to_date).to eq(Date.new(2025, 1, 6))
  #       expect(ledger.name).to eq('MFクラウド')
  #       expect(ledger.ledger_item).to eq(ledger_item_1)
  #       expect(ledger.face_value).to eq(1848)
  #       expect(ledger.recorded_amount).to eq(1848)
  #     end
  #   end
  # end
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
