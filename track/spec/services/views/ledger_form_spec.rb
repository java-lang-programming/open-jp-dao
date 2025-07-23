require 'rails_helper'

RSpec.describe Views::LedgerForm do
  describe 'initialize' do
    it 'should get form' do
      ledger_form = Views::LedgerForm.new
      form = ledger_form.form
      expect(form).to eq({
        date: { status: "ready", msg: nil },
        name: { status: "ready", msg: nil },
        face_value: { status: "ready", msg: nil },
        proportion_rate: { status: "ready", msg: nil },
        proportion_amount: { status: "ready", msg: nil }
      })
    end
  end

  describe 'execute' do
    it 'should get all attributes errors.' do
      ledger_form = Views::LedgerForm.new
      ledger = Ledger.new(proportion_rate: 0.123, proportion_amount: 'aaa')
      ledger.valid?
      ledger_form.execute(ledger: ledger)
      form = ledger_form.form

      expect(form[:date]).to eq({ status: "failure", msg: "日付を入力してください" })
      expect(form[:name]).to eq({ status: "failure", msg: "名前を入力してください" })
      expect(form[:face_value]).to eq({ status: "failure", msg: "額面を入力してください" })
      expect(form[:proportion_rate]).to eq({ status: "failure", msg: "按分率は小数点以下2桁以内で入力してください" })
      expect(form[:proportion_amount]).to eq({ status: "failure", msg: "按分額は整数で入力してください" })
    end

    it 'should be not error.' do
      ledger_form = Views::LedgerForm.new
      ledger = Ledger.new(date: '2011-01-01', name: 'test', face_value: 1000, proportion_rate: 0.12)
      ledger.valid?
      ledger_form.execute(ledger: ledger)
      form = ledger_form.form

      expect(form[:date]).to eq({ status: "complete", msg: nil })
      expect(form[:name]).to eq({ status: "complete", msg: nil })
      expect(form[:face_value]).to eq({ status: "complete", msg: nil })
      expect(form[:proportion_rate]).to eq({ status: "complete", msg: nil })
      expect(form[:proportion_amount]).to eq({ status: "complete", msg: nil })
    end
  end
end
