require 'rails_helper'

RSpec.describe Requests::DollarYensTransaction, type: :feature do
  describe 'error' do
    context 'failure when transaction_type_kind is deposit.' do
      it 'should get errors when deposit_quantity is empty.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "", deposit_quantity: "", deposit_rate: "150.12" }, transaction_type_kind: TransactionType.kinds[:deposit])
        expect(error).to eq({ date: "日付は必須入力です", deposit_quantity: "deposit_quantityは必須入力です" })
      end

      it 'should get errors when deposit_quantity is empty.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "", deposit_rate: "150.12" }, transaction_type_kind: TransactionType.kinds[:deposit])
        expect(error).to eq({ deposit_quantity: "deposit_quantityは必須入力です" })
      end

      it 'should get errors when deposit_quantity is invalid.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "aaaa", deposit_rate: "150.12" }, transaction_type_kind: TransactionType.kinds[:deposit])
        expect(error).to eq({ deposit_quantity: "deposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" })
      end

      it 'should get errors when deposit_quantity is invalid point.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "100.123", deposit_rate: "150.12" }, transaction_type_kind: TransactionType.kinds[:deposit])
        expect(error).to eq({ deposit_quantity: "deposit_quantityの値が不正です。小数点2桁までで入力してください" })
      end

      it 'should get errors when deposit_rate is empty.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "100", deposit_rate: "" }, transaction_type_kind: TransactionType.kinds[:deposit])
        expect(error).to eq({ deposit_rate: "deposit_rateは必須入力です" })
      end

      it 'should get errors when deposit_rate is empty.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "100", deposit_rate: "aaa" }, transaction_type_kind: TransactionType.kinds[:deposit])
        expect(error).to eq({ deposit_rate: "deposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" })
      end

      it 'should get errors when deposit_quantity is correct' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "1000.13", deposit_rate: "150.12" }, transaction_type_kind: TransactionType.kinds[:deposit])
        expect(error).to eq({})
      end
    end

    context 'failure when transaction_type_kind is withdrawal.' do
      it 'should get errors when withdrawal_quantity and exchange_en are empty.' do
        req = Requests::DollarYensTransaction.new(transaction_type_kind: TransactionType.kinds[:withdrawal], withdrawal_quantity: "", exchange_en: "")
        error = req.error(request: { date: "" }, transaction_type_kind: TransactionType.kinds[:withdrawal])
        expect(error).to eq({ date: "日付は必須入力です", withdrawal_quantity: "withdrawal_quantityは必須入力です", exchange_en: "exchange_enは必須入力です" })
      end

      it 'should get errors when withdrawal_quantity is empty.' do
        req = Requests::DollarYensTransaction.new(transaction_type_kind: TransactionType.kinds[:withdrawal], withdrawal_quantity: "", exchange_en: "50000")
        error = req.error(request: { date: "2022-02-11" }, transaction_type_kind: TransactionType.kinds[:withdrawal])
        expect(error).to eq({ withdrawal_quantity: "withdrawal_quantityは必須入力です" })
      end

      it 'should get errors when withdrawal_quantity is invalid.' do
        req = Requests::DollarYensTransaction.new(transaction_type_kind: TransactionType.kinds[:withdrawal], withdrawal_quantity: "adv", exchange_en: "50000")
        error = req.error(request: { date: "2022-02-11" }, transaction_type_kind: TransactionType.kinds[:withdrawal])
        expect(error).to eq({ withdrawal_quantity: "withdrawal_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" })
      end

      # 小数点
      it 'should get errors when exchange_en is invalid.' do
        req = Requests::DollarYensTransaction.new(transaction_type_kind: TransactionType.kinds[:withdrawal], withdrawal_quantity: "40.7", exchange_en: "50000.23")
        error = req.error(request: { date: "2022-02-11" }, transaction_type_kind: TransactionType.kinds[:withdrawal])
        expect(error).to eq({ exchange_en: "exchange_enの値が不正です。数値を入力してください" })
      end

      # 不正な文字
      it 'should get errors when exchange_en is invalid.' do
        req = Requests::DollarYensTransaction.new(transaction_type_kind: TransactionType.kinds[:withdrawal], withdrawal_quantity: "40.7", exchange_en: "aaaa")
        error = req.error(request: { date: "2022-02-11" }, transaction_type_kind: TransactionType.kinds[:withdrawal])
        expect(error).to eq({ exchange_en: "exchange_enの値が不正です。数値を入力してください" })
      end
    end
  end
end
