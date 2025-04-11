require 'rails_helper'

RSpec.describe Requests::DollarYensTransaction, type: :feature do
  describe 'error' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }

    context 'failure when transaction_type_kind is deposit.' do
      it 'should get errors when deposit_quantity is empty.' do
        req = Requests::DollarYensTransaction.new(date: "", transaction_type: transaction_type1, deposit_quantity: "", deposit_rate: "150.12")
        error = req.get_errors
        expect(error).to eq({ date: "日付は必須入力です", deposit_quantity: "deposit_quantityは必須入力です" })
      end

      it 'should get errors when date is invalid format.' do
        req = Requests::DollarYensTransaction.new(date: "aaaaa", transaction_type: transaction_type1, deposit_quantity: "100.12", deposit_rate: "150.12")
        error = req.get_errors
        expect(error).to eq({ date: "dateのフォーマットが不正です。yyyy-mm-dd形式で入力してください" })
      end

      it 'should get errors when date is invalid.' do
        req = Requests::DollarYensTransaction.new(date: "2022-03-32", transaction_type: transaction_type1, deposit_quantity: "100.12", deposit_rate: "150.12")
        error = req.get_errors
        expect(error).to eq({ date: "dateの値が不正です。yyyy-mm-dd形式で正しい日付を入力してください" })
      end

      it 'should get errors when deposit_quantity is invalid.' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type1, deposit_quantity: "aaaa", deposit_rate: "150.12")
        error = req.get_errors
        expect(error).to eq({ deposit_quantity: "deposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" })
      end

      it 'should get errors when deposit_quantity is invalid point.' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type1, deposit_quantity: "100.123", deposit_rate: "150.12")
        error = req.get_errors
        expect(error).to eq({ deposit_quantity: "deposit_quantityの値が不正です。小数点2桁までで入力してください" })
      end

      it 'should get errors when deposit_rate is empty.' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type1, deposit_quantity: "100", deposit_rate: "")
        error = req.get_errors
        expect(error).to eq({ deposit_rate: "deposit_rateは必須入力です" })
      end

      it 'should get errors when deposit_rate is empty.' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type1, deposit_quantity: "100", deposit_rate: "aaa")
        error = req.get_errors
        expect(error).to eq({ deposit_rate: "deposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" })
      end

      it 'should get errors when deposit_quantity is correct' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type1, deposit_quantity: "1000.13", deposit_rate: "150.12")
        error = req.get_errors
        expect(error).to eq({})
      end
    end

    context 'failure when transaction_type_kind is withdrawal.' do
      it 'should get errors when withdrawal_quantity and exchange_en are empty.' do
        req = Requests::DollarYensTransaction.new(date: "", transaction_type: transaction_type5, withdrawal_quantity: "", exchange_en: "")
        error = req.get_errors
        expect(error).to eq({ date: "日付は必須入力です", withdrawal_quantity: "withdrawal_quantityは必須入力です", exchange_en: "exchange_enは必須入力です" })
      end

      it 'should get errors when date is invalid format.' do
        req = Requests::DollarYensTransaction.new(date: "aaaaa", transaction_type: transaction_type5, withdrawal_quantity: "40.7", exchange_en: "50000")
        error = req.get_errors
        expect(error).to eq({ date: "dateのフォーマットが不正です。yyyy-mm-dd形式で入力してください" })
      end

      it 'should get errors when date is invalid.' do
        req = Requests::DollarYensTransaction.new(date: "2022-03-32", transaction_type: transaction_type5, withdrawal_quantity: "40.7", exchange_en: "50000")
        error = req.get_errors
        expect(error).to eq({ date: "dateの値が不正です。yyyy-mm-dd形式で正しい日付を入力してください" })
      end

      it 'should get errors when withdrawal_quantity is empty.' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type5, withdrawal_quantity: "", exchange_en: "50000")
        error = req.get_errors
        expect(error).to eq({ withdrawal_quantity: "withdrawal_quantityは必須入力です" })
      end

      it 'should get errors when withdrawal_quantity is invalid.' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type5, withdrawal_quantity: "adv", exchange_en: "50000")
        error = req.get_errors
        expect(error).to eq({ withdrawal_quantity: "withdrawal_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" })
      end

      # 小数点
      it 'should get errors when exchange_en is invalid.' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type5, withdrawal_quantity: "40.7", exchange_en: "50000.23")
        error = req.get_errors
        expect(error).to eq({ exchange_en: "exchange_enの値が不正です。数値を入力してください" })
      end

      # 不正な文字
      it 'should get errors when exchange_en is invalid.' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type5, withdrawal_quantity: "40.7", exchange_en: "aaaa")
        error = req.get_errors
        expect(error).to eq({ exchange_en: "exchange_enの値が不正です。数値を入力してください" })
      end

      it 'should get no errors when data is correct.' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type5, withdrawal_quantity: "40.7", exchange_en: "10000")
        error = req.get_errors
        expect(error).to eq({})
      end
    end
  end

  describe 'to_dollar_yen_transaction' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'deposit.' do
      it 'should be object' do
        req = Requests::DollarYensTransaction.new(date: "2022-02-11", transaction_type: transaction_type1, deposit_quantity: "aaaaa", deposit_rate: "bbbbb")
        errors = req.get_errors
        dollar_yen_transaction = req.to_dollar_yen_transaction(errors: errors, address: addresses_eth)
        expect(dollar_yen_transaction.date).to eq(Date.new(2022, 2, 11))
        expect(dollar_yen_transaction.address).to eq(addresses_eth)
        expect(dollar_yen_transaction.transaction_type).to eq(transaction_type1)
        expect(dollar_yen_transaction.deposit_quantity).to eq(0.0)
        expect(dollar_yen_transaction.deposit_rate).to eq(BigDecimal(0.0))
      end

      it 'should be object' do
        req = Requests::DollarYensTransaction.new(date: "", transaction_type: transaction_type1, deposit_quantity: "aaaaa", deposit_rate: "bbbbb")
        errors = req.get_errors
        dollar_yen_transaction = req.to_dollar_yen_transaction(errors: errors, address: addresses_eth)
        expect(dollar_yen_transaction.date).to be nil
        expect(dollar_yen_transaction.address).to eq(addresses_eth)
        expect(dollar_yen_transaction.transaction_type).to eq(transaction_type1)
        expect(dollar_yen_transaction.deposit_quantity).to eq(0.0)
        expect(dollar_yen_transaction.deposit_rate).to eq(0.0)
      end
    end
  end
end
