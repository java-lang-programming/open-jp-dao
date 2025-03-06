require 'rails_helper'

RSpec.describe Requests::DollarYensTransaction, type: :feature do
  describe 'error' do
    context 'failure' do
      it 'should get errors when deposit_quantity is empty.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "", deposit_quantity: "", deposit_rate: "150.12" })
        expect(error).to eq({ date: "日付は必須入力です", deposit_quantity: "deposit_quantityは必須入力です" })
      end

      it 'should get errors when deposit_quantity is empty.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "", deposit_rate: "150.12" })
        expect(error).to eq({ deposit_quantity: "deposit_quantityは必須入力です" })
      end

      it 'should get errors when deposit_quantity is invalid.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "aaaa", deposit_rate: "150.12" })
        expect(error).to eq({ deposit_quantity: "deposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" })
      end

      it 'should get errors when deposit_quantity is invalid point.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "100.123", deposit_rate: "150.12" })
        expect(error).to eq({ deposit_quantity: "deposit_quantityの値が不正です。小数点2桁までで入力してください" })
      end

      it 'should get errors when deposit_rate is empty.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "100", deposit_rate: "" })
        expect(error).to eq({ deposit_rate: "deposit_rateは必須入力です" })
      end

      it 'should get errors when deposit_rate is empty.' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "100", deposit_rate: "aaa" })
        expect(error).to eq({ deposit_rate: "deposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" })
      end

      it 'should get errors when deposit_quantity is correct' do
        req = Requests::DollarYensTransaction.new
        error = req.error(request: { date: "2022-02-11", deposit_quantity: "1000.13", deposit_rate: "150.12" })
        expect(error).to eq({})
      end
    end
  end
end
