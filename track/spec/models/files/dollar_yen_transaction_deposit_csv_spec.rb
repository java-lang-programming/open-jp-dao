require 'rails_helper'

# https://github.com/willnet/rspec-style-guide
RSpec.describe Files::DollarYenTransactionDepositCsv, type: :model do
  describe 'valid_deposit_quantity?' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'deposit_quantityがない場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = []
        errors = csv.valid_deposit_quantity?(errors: errors)
        expect(errors).to eq([ "2行目のdeposit_quantityが入力されていません" ])
      end
    end

    context 'deposit_quantityが不正の場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "aaaa", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = []
        errors = csv.valid_deposit_quantity?(errors: errors)
        expect(errors).to eq([ "2行目のdeposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
      end
    end

    context 'deposit_quantityが数値の場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "100", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = []
        errors = csv.valid_deposit_quantity?(errors: errors)
        expect(errors).to eq([])
      end
    end

    context 'deposit_quantityが小数点付きの数値の場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = []
        errors = csv.valid_deposit_quantity?(errors: errors)
        expect(errors).to eq([])
      end
    end
  end

  describe 'valid_deposit_rate?' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'deposit_rateがない場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = []
        errors = csv.valid_deposit_rate?(errors: errors)
        expect(errors).to eq([ "2行目のdeposit_rateが入力されていません" ])
      end
    end

    context 'deposit_rateが不正の場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "bbbb" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = []
        errors = csv.valid_deposit_rate?(errors: errors)
        expect(errors).to eq([ "2行目のdeposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
      end
    end

    context 'deposit_rateが数値の場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = []
        errors = csv.valid_deposit_rate?(errors: errors)
        expect(errors).to eq([])
      end
    end

    context 'deposit_rateが小数点付きの数値の場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = []
        errors = csv.valid_deposit_rate?(errors: errors)
        expect(errors).to eq([])
      end
    end
  end


  describe 'valid_errors' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'エラーがない場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([])
      end
    end

    context '日付エラー' do
      it 'should be error when date is empty.' do
        transaction_type1
        row = [ "", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "2行目のdateが入力されていません" ])
      end

      it 'should be error when date is invalid format.' do
        transaction_type1
        row = [ "2020-04-01", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "2行目のdateのフォーマットが不正です。yyyy/mm/dd形式で入力してください" ])
      end

      it 'should be error when date is invalid date.' do
        transaction_type1
        row = [ "2020/04/33", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "2行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ])
      end

      it 'should be error when date is invalid date2.' do
        transaction_type1
        row = [ "aaaa/bb/cc", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "2行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ])
      end
    end

    context '日付エラー' do
      it 'should be error when date is empty.' do
        transaction_type1
        row = [ "2020/04/01", "", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "2行目のtransaction_typeが入力されていません" ])
      end

      it 'should be error when transaction_type is error.' do
        row = [ "2020/04/01", "SPA配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "2行目のtransaction_typeが不正です。正しいtransaction_typeを入力してください" ])
      end
    end

    context 'deposit_quantityエラー' do
      it 'should be error when deposit_quantity is empty.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "2行目のdeposit_quantityが入力されていません" ])
      end

      it 'should be error when deposit_quantity is invalid.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "aaa", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 3, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "3行目のdeposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
      end
    end

    context 'deposit_rateエラー' do
      it 'should be error when deposit_rate is empty.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "10", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "2行目のdeposit_rateが入力されていません" ])
      end

      it 'should be error when deposit_rate is invalid.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "10", "cccc" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 3, row: row)
        errors = csv.valid_errors
        expect(errors).to eq([ "3行目のdeposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
      end
    end
  end
end
