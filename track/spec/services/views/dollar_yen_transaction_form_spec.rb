require 'rails_helper'

RSpec.describe Views::DollarYenTransactionForm do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
  let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
  let(:valid_date) { '2020-1-1' }
  # 有効な受け取った米ドル
  let(:valid_deposit_quantity) { 100.89 }
  let(:deposit_rate) { 150.12 }
  let(:valid_exchange_en) { 10000 }

  describe 'initialize' do
    it 'should get form when transaction_type.deposit? is true.' do
      view_form = Views::DollarYenTransactionForm.new(transaction_type: transaction_type1)
      form_status = view_form.form_status
      expect(form_status).to eq({
        deposit?: true,
        withdrawal?: false,
        date: { status: Views::Status::STATUS_READY, msg: nil },
        deposit_quantity: { status: Views::Status::STATUS_READY, msg: nil },
        deposit_rate: { status: Views::Status::STATUS_READY, msg: nil },
        withdrawal_quantity: { status: Views::Status::STATUS_READY, msg: nil },
        exchange_en: { status: Views::Status::STATUS_READY, msg: nil }
      })
    end

    it 'should get form when transaction_type.withdrawal? is true.' do
      view_form = Views::DollarYenTransactionForm.new(transaction_type: transaction_type5)
      form_status = view_form.form_status
      expect(form_status).to eq({
        deposit?: false,
        withdrawal?: true,
        date: { status: Views::Status::STATUS_READY, msg: nil },
        deposit_quantity: { status: Views::Status::STATUS_READY, msg: nil },
        deposit_rate: { status: Views::Status::STATUS_READY, msg: nil },
        withdrawal_quantity: { status: Views::Status::STATUS_READY, msg: nil },
        exchange_en: { status: Views::Status::STATUS_READY, msg: nil }
      })
    end
  end

  describe 'execute' do
    context 'deposit' do
      let(:view_form) { view_form = Views::DollarYenTransactionForm.new(transaction_type: transaction_type1) }

      before do
        addresses_eth
        transaction_type1
        transaction_type5
      end

      # 必須
      it 'should get attributes errors.' do
        dollar_yen_transaction = DollarYenTransaction.new(date: nil, deposit_quantity: nil, deposit_rate: nil)
        dollar_yen_transaction.address = addresses_eth
        dollar_yen_transaction.transaction_type = transaction_type1
        dollar_yen_transaction.valid?
        view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
        form_status = view_form.form_status

        expect(form_status[:date]).to eq({ status: "failure", msg: "日付を入力してください" })
        expect(form_status[:deposit_quantity]).to eq({ status: "failure", msg: "受け取った米ドルを入力してください" })
        expect(form_status[:deposit_rate]).to eq({ status: "failure", msg: "米ドル円レートを入力してください" })
        expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
        expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
      end

      # deposit_quantity
      context 'deposit_quantity' do
        # 数値以外のエラー
        it 'should get attributes errors.' do
          dollar_yen_transaction = DollarYenTransaction.new(date: valid_date, deposit_quantity: "aaaa", deposit_rate: deposit_rate)
          dollar_yen_transaction.address = addresses_eth
          dollar_yen_transaction.transaction_type = transaction_type1
          dollar_yen_transaction.valid?
          view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
          form_status = view_form.form_status

          expect(form_status[:date]).to eq({ status: "complete", msg: nil })
          expect(form_status[:deposit_quantity]).to eq({ status: "failure", msg: "受け取った米ドルは数値で入力してください" })
          expect(form_status[:deposit_rate]).to eq({ status: "complete", msg: nil })
          expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
        end

        # 小数点の桁のエラー
        it 'should get attributes errors.' do
          dollar_yen_transaction = DollarYenTransaction.new(date: valid_date, deposit_quantity: 100.123, deposit_rate: deposit_rate)
          dollar_yen_transaction.address = addresses_eth
          dollar_yen_transaction.transaction_type = transaction_type1
          dollar_yen_transaction.valid?
          view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
          form_status = view_form.form_status

          expect(form_status[:date]).to eq({ status: "complete", msg: nil })
          expect(form_status[:deposit_quantity]).to eq({ status: "failure", msg: "受け取った米ドルは小数点以下2桁以内で入力してください" })
          expect(form_status[:deposit_rate]).to eq({ status: "complete", msg: nil })
          expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
        end

        # マイナスを付加した場合
        it 'should get attributes errors.' do
          dollar_yen_transaction = DollarYenTransaction.new(date: valid_date, deposit_quantity: -10.12, deposit_rate: deposit_rate)
          dollar_yen_transaction.address = addresses_eth
          dollar_yen_transaction.transaction_type = transaction_type1
          dollar_yen_transaction.valid?
          view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
          form_status = view_form.form_status

          expect(form_status[:date]).to eq({ status: "complete", msg: nil })
          expect(form_status[:deposit_quantity]).to eq({ status: "failure", msg: "受け取った米ドルは0以上の値で入力してください" })
          expect(form_status[:deposit_rate]).to eq({ status: "complete", msg: nil })
          expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
        end

        # 成功
        it 'should be success.' do
          dollar_yen_transaction = DollarYenTransaction.new(date: valid_date, deposit_quantity: valid_deposit_quantity, deposit_rate: deposit_rate)
          dollar_yen_transaction.address = addresses_eth
          dollar_yen_transaction.transaction_type = transaction_type1
          dollar_yen_transaction.valid?
          view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
          form_status = view_form.form_status

          expect(form_status[:date]).to eq({ status: "complete", msg: nil })
          expect(form_status[:deposit_quantity]).to eq({ status: "complete", msg: nil })
          expect(form_status[:deposit_rate]).to eq({ status: "complete", msg: nil })
          expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
        end
      end

      # deposit_rate
      context 'deposit_rate' do
        # 必須エラー
        it 'should get attributes errors.' do
          dollar_yen_transaction = DollarYenTransaction.new(date: valid_date, deposit_quantity: valid_deposit_quantity, deposit_rate: "aaa")
          dollar_yen_transaction.address = addresses_eth
          dollar_yen_transaction.transaction_type = transaction_type1
          dollar_yen_transaction.valid?
          view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
          form_status = view_form.form_status

          expect(form_status[:date]).to eq({ status: "complete", msg: nil })
          expect(form_status[:deposit_quantity]).to eq({ status: "complete", msg: nil })
          expect(form_status[:deposit_rate]).to eq({ status: "failure", msg: "米ドル円レートは数値で入力してください" })
          expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
        end

        # 小数点の桁のエラー
        it 'should get attributes errors.' do
          dollar_yen_transaction = DollarYenTransaction.new(date: valid_date, deposit_quantity: valid_deposit_quantity, deposit_rate: 100.123)
          dollar_yen_transaction.address = addresses_eth
          dollar_yen_transaction.transaction_type = transaction_type1
          dollar_yen_transaction.valid?
          view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
          form_status = view_form.form_status

          expect(form_status[:date]).to eq({ status: "complete", msg: nil })
          expect(form_status[:deposit_quantity]).to eq({ status: "complete", msg: nil })
          expect(form_status[:deposit_rate]).to eq({ status: "failure", msg: "米ドル円レートは小数点以下2桁以内で入力してください" })
          expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
        end

        # マイナスを付加した場合
        it 'should get attributes errors.' do
          dollar_yen_transaction = DollarYenTransaction.new(date: valid_date, deposit_quantity: valid_deposit_quantity, deposit_rate: -100.12)
          dollar_yen_transaction.address = addresses_eth
          dollar_yen_transaction.transaction_type = transaction_type1
          dollar_yen_transaction.valid?
          view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
          form_status = view_form.form_status

          expect(form_status[:date]).to eq({ status: Views::Status::STATUS_COMPLETE, msg: nil })
          expect(form_status[:deposit_quantity]).to eq({ status: Views::Status::STATUS_COMPLETE, msg: nil })
          expect(form_status[:deposit_rate]).to eq({ status: Views::Status::STATUS_FAILURE, msg: "米ドル円レートは0以上の値で入力してください" })
          expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
        end

        # 成功
        it 'should be success.' do
          dollar_yen_transaction = DollarYenTransaction.new(date: valid_date, deposit_quantity: valid_deposit_quantity, deposit_rate: 100)
          dollar_yen_transaction.address = addresses_eth
          dollar_yen_transaction.transaction_type = transaction_type1
          dollar_yen_transaction.valid?
          view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
          form_status = view_form.form_status

          expect(form_status[:date]).to eq({ status: Views::Status::STATUS_COMPLETE, msg: nil })
          expect(form_status[:deposit_quantity]).to eq({ status: Views::Status::STATUS_COMPLETE, msg: nil })
          expect(form_status[:deposit_rate]).to eq({ status: Views::Status::STATUS_COMPLETE, msg: nil })
          expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
        end
      end
    end

    context 'withdrawal' do
      let(:view_form) { view_form = Views::DollarYenTransactionForm.new(transaction_type: transaction_type5) }

      before do
        addresses_eth
        transaction_type1
        transaction_type5
      end

      # deposit_quantity
      context 'deposit_quantity' do
        # 必須エラー
        it 'should get attributes errors.' do
          dollar_yen_transaction = DollarYenTransaction.new(date: valid_date, withdrawal_quantity: nil, exchange_en: valid_exchange_en)
          dollar_yen_transaction.address = addresses_eth
          dollar_yen_transaction.transaction_type = transaction_type5
          dollar_yen_transaction.valid?
          view_form.execute(dollar_yen_transaction: dollar_yen_transaction)
          form_status = view_form.form_status

          expect(form_status[:date]).to eq({ status: Views::Status::STATUS_COMPLETE, msg: nil })
          expect(form_status[:deposit_quantity]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:deposit_rate]).to eq({ status: Views::Status::STATUS_READY, msg: nil })
          expect(form_status[:withdrawal_quantity]).to eq({ status: Views::Status::STATUS_FAILURE, msg: "売却した米ドルは数値で入力してください" })
          expect(form_status[:exchange_en]).to eq({ status: Views::Status::STATUS_COMPLETE, msg: nil })
        end
      end
    end
  end
end
