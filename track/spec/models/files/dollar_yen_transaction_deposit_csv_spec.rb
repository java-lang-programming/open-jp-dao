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

  describe 'unique_key' do
    let(:addresses_eth) { create(:addresses_eth) }

    it 'should get unique_key.' do
      row = [ "2020/04/01", "HDV配当入金", "10", "" ]
      csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
      expect(csv.unique_key).to eq("2020/04/01-HDV配当入金")
    end
  end

  describe 'unique_key_hash' do
    let(:addresses_eth) { create(:addresses_eth) }
    it 'should get unique_key_hash.' do
      h = {}
      row = [ "2020/04/01", "HDV配当入金", "10", "" ]
      csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
      h = csv.unique_key_hash(unique_key_hash: h)
      csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 4, row: row)
      h = csv.unique_key_hash(unique_key_hash: h)

      expect(h).to eq({ "2020/04/01-HDV配当入金"=>{ rownums: [ 2, 4 ] } })
    end
  end

  describe 'target_date' do
    let(:addresses_eth) { create(:addresses_eth) }
    it 'should get target_date of Date Type.' do
      row = [ "2020/04/01", "HDV配当入金", "10", "" ]
      csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)

      expect(csv.target_date).to eq(Date.new(2020, 4, 1))
    end
  end

  describe 'to_dollar_yen_transaction' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }

    # 　初回データ
    it 'should get first data.' do
      # transaction_type1の実体化
      transaction_type1
      row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59" ]
      csv = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: row)
      dollar_yen_transaction = csv.to_dollar_yen_transaction
      expect(dollar_yen_transaction.transaction_type).to eq(transaction_type1)
      expect(dollar_yen_transaction.date).to eq(Date.new(2020, 4, 1))
      expect(dollar_yen_transaction.deposit_rate).to eq(dollar_yen_transaction1.deposit_rate)
      expect(dollar_yen_transaction.deposit_quantity).to eq(dollar_yen_transaction1.deposit_quantity)
      expect(dollar_yen_transaction.deposit_en).to eq(dollar_yen_transaction1.deposit_en)
      expect(dollar_yen_transaction.balance_rate.truncate(6)).to eq(dollar_yen_transaction1.balance_rate.truncate(6))
      expect(dollar_yen_transaction.balance_quantity.truncate(6)).to eq(dollar_yen_transaction1.balance_quantity.truncate(6))
      expect(dollar_yen_transaction.balance_en.truncate(6)).to eq(dollar_yen_transaction1.balance_en.truncate(6))
    end

    # 　次のデータ
    it 'should get next data.' do
      # transaction_type1の実体化
      transaction_type1
      data_row1 = [ "2020/04/01", "HDV配当入金", "3.97", "106.59" ]
      data_row2 = [ "2020/06/19", "HDV配当入金", "10.76", "105.95" ]
      csv_line1 = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 2, row: data_row1)
      dollar_yen_transaction1 = csv_line1.to_dollar_yen_transaction
      csv_line2 = Files::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, row_num: 3, row: data_row2)
      dollar_yen_transaction2 = csv_line2.to_dollar_yen_transaction(previous_dollar_yen_transactions: dollar_yen_transaction1)

      expect(dollar_yen_transaction2.transaction_type).to eq(transaction_type1)
      expect(dollar_yen_transaction2.date).to eq(Date.new(2020, 6, 19))
      expect(dollar_yen_transaction2.deposit_rate).to eq(dollar_yen_transaction2.deposit_rate)
      expect(dollar_yen_transaction2.deposit_en).to eq(dollar_yen_transaction2.deposit_en)
      expect(dollar_yen_transaction2.balance_rate.truncate(6)).to eq(dollar_yen_transaction2.balance_rate.truncate(6))
      expect(dollar_yen_transaction2.balance_quantity.truncate(6)).to eq(dollar_yen_transaction2.balance_quantity.truncate(6))
      expect(dollar_yen_transaction2.deposit_en.truncate(6)).to eq(dollar_yen_transaction2.deposit_en.truncate(6))
    end
  end
end
