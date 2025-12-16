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
  let(:row_1_comma_separated_face_value) {
    [ '2025/01/06', '通信費', 'MFクラウド', '1,848', nil, nil ]
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
                                       message: "通信はledger_itemに存在しません"
                                     })
      end
    end
  end

  describe 'data_for_ledger' do
    context 'csvに記述されたnameのエラーを取得する' do
      it 'should get date.' do
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        expect(csv_row.data_for_ledger(field: "date")).to eq(Date.new(2025, 1, 6))
      end

      it 'should get name.' do
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        expect(csv_row.data_for_ledger(field: "name")).to eq('MFクラウド')
      end

      context 'when face_value' do
        # カンマなしface_value
        it 'should get face_value.' do
          preload = { address: addresses_eth, ledger_items: LedgerItem.all }
          csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
          expect(csv_row.data_for_ledger(field: "face_value")).to eq(1848)
        end

        # カンマありface_value
        it 'should get face_value.' do
          preload = { address: addresses_eth, ledger_items: LedgerItem.all }
          csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1_comma_separated_face_value, preload: preload)
          expect(csv_row.data_for_ledger(field: "face_value")).to eq(1848)
        end
      end


      it 'should get proportion_rate.' do
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        expect(csv_row.data_for_ledger(field: "proportion_rate")).to be nil
      end

      it 'should get proportion_amount.' do
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        expect(csv_row.data_for_ledger(field: "proportion_amount")).to be nil
      end
    end
  end

  describe 'to_ledger' do
    context 'Ledgerオブジェクトを取得する' do
      it 'should get ledger.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        ledger = csv_row.to_ledger
        expect(ledger.date.to_date).to eq(Date.new(2025, 1, 6))
        expect(ledger.name).to eq('MFクラウド')
        expect(ledger.ledger_item).to eq(ledger_item_1)
        expect(ledger.face_value).to eq(1848)
        expect(ledger.recorded_amount).to eq(1848)
      end
    end
  end

  describe 'to_upsert_all_ledger' do
    context 'upsert_allを実行するためのhashを取得する' do
      it 'should get hashed data.' do
        ledger_item_1
        preload = { address: addresses_eth, ledger_items: LedgerItem.all }
        csv_row = Files::LedgerImportCsvRow.new(master: master, row_num: 1, row: row_1, preload: preload)
        hash = csv_row.to_upsert_all_ledger
        expect(hash[:date]).to eq(Date.new(2025, 1, 6))
        expect(hash[:name]).to eq('MFクラウド')
        expect(hash[:ledger_item_id]).to eq(ledger_item_1.id)
        expect(hash[:face_value]).to eq(1848)
        expect(hash[:proportion_rate]).to be nil
        expect(hash[:proportion_amount]).to be nil
        expect(hash[:recorded_amount]).to eq(1848)
        expect(hash[:address_id]).to eq(addresses_eth.id)
      end
    end
  end
end
