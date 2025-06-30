require 'rails_helper'

RSpec.describe Files::LedgerImportCsvRow do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:master) { FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::LEDGER_YAML).master }
  let(:preload) {
    { address: addresses_eth, ledger_items: LedgerItem.all }
  }
  let(:ledger_item_1) {
    create(:ledger_item_1)
  }
  let(:row_1) {
    [ '2025/01/06', '通信費', 'MFクラウド', '1848', nil, nil ]
  }

  describe 'ledger_item_col_index' do
    context 'ledger_itemのcol_indexを取得する' do
      it 'should get ledger_item index.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        col_index = csv_row.ledger_item_col_index
        expect(col_index).to eq(1)
      end
    end
  end

  describe 'find_ledger_item_by_name' do
    context 'csvに記述されたデータからledger_itemを取得する' do
      it 'should get ledger_item object.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        ledger_item = csv_row.find_ledger_item_by_name
        expect(ledger_item).to eq(ledger_item_1)
      end

      it 'should get nil.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        row = [ '2025/01/06', '通信', 'MFクラウド', '1848', nil, nil ]
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row, preload: preload)
        ledger_item = csv_row.find_ledger_item_by_name
        expect(ledger_item).to be nil
      end
    end
  end

  describe 'validate_error_of_name' do
    context 'csvに記述されたnameのエラーを取得する' do
      it 'should no error.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        validate_error = csv_row.validate_error_of_name
        expect(validate_error).to be nil
      end

      it 'should get error object.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        row = [ '2025/01/06', '通信', 'MFクラウド', '1848', nil, nil ]
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row, preload: preload)
        validate_error = csv_row.validate_error_of_name
        expect(validate_error).to eq({
                                       row: 1,
                                       col: 2,
                                       attribute: 'ledger_item',
                                       value: '通信',
                                       messaga: "通信はledger_itemに存在しません"
                                     })
      end
    end
  end

  describe 'data_for_ledger' do
    context 'csvに記述されたnameのエラーを取得する' do
      it 'should get date.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        expect(csv_row.data_for_ledger(field: "date")).to eq(Date.new(2025, 1, 6))
      end

      it 'should get name.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        expect(csv_row.data_for_ledger(field: "name")).to eq('MFクラウド')
      end

      it 'should get face_value.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        expect(csv_row.data_for_ledger(field: "face_value")).to eq(BigDecimal(1848))
      end

      it 'should get proportion_rate.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        expect(csv_row.data_for_ledger(field: "proportion_rate")).to be nil
      end

      it 'should get proportion_amount.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        expect(csv_row.data_for_ledger(field: "proportion_amount")).to be nil
      end
    end
  end
end
