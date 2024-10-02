require 'rails_helper'

# https://github.com/willnet/rspec-style-guide
RSpec.describe Files::DollarYenTransactionDepositCsv, type: :model do
  # let(:addresses_eth) { create(:addresses_eth) }
  # let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

  describe 'valid?' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    # let(:addresses_eth) { create(:addresses_eth) }
    # let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    # let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    # let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    # let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context 'エラーがない場合' do
      it 'should be [].' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(row_num: 2, row: row)
        errors = csv.valid?
        expect(errors).to eq([])
      end
    end

    context '日付エラー' do
      it 'should be error when date is empty.' do
        transaction_type1
        row = [ "", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(row_num: 2, row: row)
        errors = csv.valid?
        expect(errors).to eq([ "2行目のdateが入力されていません" ])
      end

      it 'should be error when date is invalid format.' do
        transaction_type1
        row = [ "2020-04-01", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(row_num: 2, row: row)
        errors = csv.valid?
        expect(errors).to eq([ "2行目のdateのフォーマットが不正です。yyyy/mm/dd形式で入力してください" ])
      end

      it 'should be error when date is invalid date.' do
        transaction_type1
        row = [ "2020/04/33", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(row_num: 2, row: row)
        errors = csv.valid?
        expect(errors).to eq([ "2行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ])
      end

      it 'should be error when date is invalid date2.' do
        transaction_type1
        row = [ "aaaa/bb/cc", "HDV配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(row_num: 2, row: row)
        errors = csv.valid?
        expect(errors).to eq([ "2行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ])
      end
    end

    context '日付エラー' do
      it 'should be error when date is empty.' do
        transaction_type1
        row = [ "2020/04/01", "", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(row_num: 2, row: row)
        errors = csv.valid?
        expect(errors).to eq([ "2行目のtransaction_typeが入力されていません" ])
      end

      it 'should be error when transaction_type is error.' do
        row = [ "2020/04/01", "SPA配当入金", "3.97", "106.59" ]
        csv = Files::DollarYenTransactionDepositCsv.new(row_num: 2, row: row)
        errors = csv.valid?
        expect(errors).to eq([ "2行目のtransaction_typeが不正です。正しいtransaction_typeを入力してください" ])
      end
    end
  end
end
