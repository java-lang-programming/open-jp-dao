require 'rails_helper'

RSpec.describe FileUploads::DollarYenTransactionDepositCsv, type: :feature do
  # let(:addresses_eth) { create(:addresses_eth) }
  # let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

  describe 'deposit?' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:error_deposit_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/error_deposit.csv" }
    let(:deposit_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_csv.csv" }
    let(:deposit_three_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_three_csv.csv" }
    let(:deposit_and_withdrawal_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_and_withdrawal.csv" }

    context 'validation_errors' do
      it 'should get validation_errors.' do
        transaction_type1
        service = FileUploads::DollarYenTransactionDepositCsv.new(address: addresses_eth, file: error_deposit_csv_path)
        expect(service.validation_errors).to eq([
          { msg: [ "2行目のdateが入力されていません" ] },
          { msg: [ "3行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください", "3行目のtransaction_type_nameが入力されていません" ] },
          { msg: [ "4行目のdeposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" ] },
          { msg: [ "5行目のdeposit_rateが入力されていません" ] },
          { msg: [ "6行目のdeposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" ] }
        ])
      end
    end

    context 'unique_keys_errors' do
      it 'should get unique_keys_errors.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "10", "" ]
        h = {}
        csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth.id, row_num: 2, row: row)
        h = csv.unique_key_hash(unique_key_hash: h)
        csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth.id, row_num: 4, row: row)
        h = csv.unique_key_hash(unique_key_hash: h)

        service = FileUploads::DollarYenTransactionDepositCsv.new(address: addresses_eth, file: error_deposit_csv_path)
        errors = service.unique_keys_errors(unique_key_hash: h)

        expect(errors).to eq([
          "2行目の2020/04/01とHDV配当入金は重複しています",
          "4行目の2020/04/01とHDV配当入金は重複しています"
        ])
      end

      # 　エラーなし
      it 'should empty array unique_keys_errors.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "10", "120" ]
        row2 = [ "2020/04/02", "HDV配当入金", "10", "100" ]
        h = {}
        csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
        h = csv.unique_key_hash(unique_key_hash: h)
        csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 4, row: row2)
        h = csv.unique_key_hash(unique_key_hash: h)

        service = FileUploads::DollarYenTransactionDepositCsv.new(address: addresses_eth, file: error_deposit_csv_path)
        errors = service.unique_keys_errors(unique_key_hash: h)

        expect(errors).to eq([])
      end
    end
  end
end
