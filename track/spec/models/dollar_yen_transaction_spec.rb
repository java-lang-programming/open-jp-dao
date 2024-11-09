require 'rails_helper'

# https://github.com/willnet/rspec-style-guide
RSpec.describe DollarYenTransaction, type: :model do
  # let(:addresses_eth) { create(:addresses_eth) }
  # let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

  describe 'deposit?' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context 'depositの場合' do
      it 'should be true.' do
        expect(dollar_yen_transaction1.deposit?).to be true
      end

      it 'should be false.' do
        expect(dollar_yen_transaction44.deposit?).to be false
      end
    end
  end

  describe 'withdrawal?' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context 'withdrawalの場合' do
      it 'should be false.' do
        expect(dollar_yen_transaction1.withdrawal?).to be false
      end

      it 'should be true.' do
        expect(dollar_yen_transaction44.withdrawal?).to be true
      end
    end
  end

  describe 'validates deposit_rate' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'deposit_rateが文字列' do
      # 文字列はNG
      it 'should be NG when string rate.' do
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, deposit_rate: 'aaa')
        dyt.valid?
        expect(dyt.errors.messages[:deposit_rate]).to include('is not a number')
      end
    end

    context 'deposit_rateが小数点のない数値' do
      # 　小数点のない数値
      it 'should be NG when deposit_rate integer.' do
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, deposit_rate: 1000)
        dyt.valid?
        expect(dyt.errors.messages[:deposit_rate]).to eq([])
      end
    end

    context 'deposit_rateが小数点のない数値' do
      # 　小数点のない数値
      it 'should be OK when deposit_rate real.' do
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, deposit_rate: 106.59)
        dyt.valid?
        expect(dyt.errors.messages[:deposit_rate]).to eq([])
      end
    end
  end

  describe 'validates deposit_quantity' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'deposit_quantityが文字列' do
      # 文字列はNG
      it 'should be NG when string deposit_quantity.' do
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, deposit_quantity: 'aaa')
        dyt.valid?
        expect(dyt.errors.messages[:deposit_quantity]).to include('is not a number')
      end
    end

    context 'deposit_quantityが小数点のない数値' do
      # 　小数点のない数値
      it 'should be OK when quantity integer.' do
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, deposit_quantity: 1000)
        dyt.valid?
        expect(dyt.errors.messages[:deposit_quantity]).to eq([])
      end
    end

    context 'deposit_quantityが小数点のない数値' do
      # 　小数点のない数値
      it 'should be OK when deposit_quantity real.' do
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, deposit_quantity: 106.59)
        dyt.valid?
        expect(dyt.errors.messages[:deposit_quantity]).to eq([])
      end
    end
  end

  describe 'validates valid' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'データ正常' do
      # 　小数点のない数値
      it 'should be OK ' do
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, deposit_rate: 106.59, deposit_quantity: 3.97)
        dyt.valid?
        expect(dyt.errors.messages[:deposit_quantity]).to eq([])
      end
    end
  end

  describe 'calculate_deposit_en' do
    context '両方データがある' do
      # 　小数点のない数値
      it 'should be OK.' do
        dyt = DollarYenTransaction.new(deposit_rate: 106.59, deposit_quantity: 3.97)
        expect(dyt.calculate_deposit_en).to eq(423)
        dyt2 = DollarYenTransaction.new(deposit_rate: 105.95, deposit_quantity: 10.76)
        expect(dyt2.calculate_deposit_en).to eq(1140)
      end
    end

    context '両方データがない' do
      # TypeErrorが発生
      it 'should be OK.' do
        dyt = DollarYenTransaction.new
        expect do
          dyt.calculate_deposit_en
        end.to raise_error(TypeError)
      end
    end
  end

  describe 'calculate_withdrawal_rate' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction43) { create(:dollar_yen_transaction43, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context '前の保存データがある' do
      it 'should be OK.' do
        dollar_yen_transaction43
        target_date = Date.new(2024, 2, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type5, withdrawal_quantity: 88)
        withdrawal_rate = dyt.calculate_withdrawal_rate(target_date: target_date)
        expect(withdrawal_rate).to eq(dollar_yen_transaction44.withdrawal_rate)
      end
    end
  end

  describe 'calculate_withdrawal_en' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction43) { create(:dollar_yen_transaction43, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context '前の保存データがある' do
      # 　小数点のない数値
      it 'should be OK.' do
        dollar_yen_transaction43
        target_date = Date.new(2024, 2, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type5, withdrawal_quantity: 88)
        withdrawal_en = dyt.calculate_withdrawal_en(target_date: target_date)
        expect(withdrawal_en.to_i).to eq(dollar_yen_transaction44.withdrawal_en.to_i)
      end
    end
  end

  describe 'calculate_exchange_difference' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction43) { create(:dollar_yen_transaction43, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context '差分計算' do
      # 　小数点のない数値
      it 'should be OK.' do
        dollar_yen_transaction43
        target_date = Date.new(2024, 2, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type5, withdrawal_quantity: 88, exchange_en: 12918)
        exchange_difference = dyt.calculate_exchange_difference(withdrawal_en: dollar_yen_transaction44.withdrawal_en)
        expect(BigDecimal(exchange_difference).round).to eq(BigDecimal(dollar_yen_transaction44.exchange_difference).round)
      end
    end
  end

  describe 'calculate_balance_quantity' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction43) { create(:dollar_yen_transaction43, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context '入金の数量データを作成' do
      it 'should be first balance_quantity.' do
        target_date = Date.new(2020, 4, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 106.59, deposit_quantity: 3.97, address: addresses_eth)
        balance_quantity = dyt.calculate_balance_quantity(target_date: target_date)
        expect(balance_quantity).to eq(3.97)
      end

      it 'should be next balance_quantity.' do
        # 　データの実態化
        dollar_yen_transaction1
        target_date = Date.new(2020, 4, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 105.95, deposit_quantity: 10.76, address: addresses_eth)
        balance_quantity = dyt.calculate_balance_quantity(target_date: target_date)
        expect(balance_quantity).to eq(dollar_yen_transaction2.balance_quantity)
      end
    end

    context '出金の数量データを作成' do
      it 'should be balance_quantity.' do
        dollar_yen_transaction43
        target_date = Date.new(2024, 2, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type5, withdrawal_quantity: 88)
        balance_quantity = dyt.calculate_balance_quantity(target_date: target_date)
        expect(balance_quantity).to eq(dollar_yen_transaction44.balance_quantity)
      end
    end
  end

  describe 'calculate_balance_en' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }

    context '残高円データを作成' do
      it 'should be first balance_quantity.' do
        target_date = Date.new(2020, 4, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 106.59, deposit_quantity: 3.97, address: addresses_eth)
        balance_en = dyt.calculate_balance_en(target_date: target_date)
        expect(balance_en).to eq(423)
      end

      it 'should be next balance_en.' do
        # 　データの実態化
        dollar_yen_transaction1
        target_date = Date.new(2020, 4, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 105.95, deposit_quantity: 10.76, address: addresses_eth)
        balance_en = dyt.calculate_balance_en(target_date: target_date)
        expect(balance_en).to eq(dollar_yen_transaction2.balance_en)
      end
    end
  end

  describe 'calculate_balance_rate' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }

    context '次の残高レートデータを作成' do
      it 'should be next balance_rate.' do
        # 　データの実態化
        target_date = Date.new(2020, 4, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 105.95, deposit_quantity: 10.76, address: addresses_eth)
        balance_rate = dyt.calculate_balance_rate(balance_quantity: "14.73", balance_en: "1563")
        expect(balance_rate.truncate(6)).to eq(BigDecimal(dollar_yen_transaction2.balance_rate).truncate(6))
      end
    end
  end

  describe 'calculate_foreign_exchange_gain' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction43) { create(:dollar_yen_transaction43, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context '為替差額計算' do
      it 'should be 0 withdrawal' do
        start_date = Date.new(2024, 1, 1)
        end_date = Date.new(2024, 12, 31)
        result = DollarYenTransaction.calculate_foreign_exchange_gain(start_date: start_date, end_date: end_date)
        expect(result).to eq({ sum: 0, withdrawal_transactions: [] })
      end

      it 'should be 1 withdrawal' do
        dollar_yen_transaction43
        dollar_yen_transaction44
        start_date = Date.new(2024, 1, 1)
        end_date = Date.new(2024, 12, 31)
        result = DollarYenTransaction.calculate_foreign_exchange_gain(start_date: start_date, end_date: end_date)
        expect(result[:sum]).to eq(BigDecimal(dollar_yen_transaction44.exchange_difference))
        expect(result[:withdrawal_transactions]).to eq([ dollar_yen_transaction44 ])
      end
    end
  end
end
