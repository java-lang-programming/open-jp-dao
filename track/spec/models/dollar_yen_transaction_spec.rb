require 'rails_helper'

# https://github.com/willnet/rspec-style-guide
RSpec.describe DollarYenTransaction, type: :model do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

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

    context '前のデータからwithdrawal_rateを計算' do
      # 　引数に指定した時は引数のデータを使う
      it 'should calculate　withdrawal_rate when previous_dollar_yen_transactions arg is found.' do
        dollar_yen_transaction43
        target_date = Date.new(2024, 2, 1)
        dyt = DollarYenTransaction.new(date: target_date, transaction_type: transaction_type5, withdrawal_quantity: 88, address: addresses_eth)
        withdrawal_rate = dyt.calculate_withdrawal_rate(previous_dollar_yen_transactions: dollar_yen_transaction43)
        expect(withdrawal_rate).to eq(dollar_yen_transaction44.withdrawal_rate)
      end

      # 　引数に指定しなかった時はデータベースから取得
      it 'should calculate　withdrawal_rate when previous_dollar_yen_transactions arg is not found.' do
        dollar_yen_transaction43
        target_date = Date.new(2024, 2, 1)
        dyt = DollarYenTransaction.new(date: target_date, transaction_type: transaction_type5, withdrawal_quantity: 88, address: addresses_eth)
        withdrawal_rate = dyt.calculate_withdrawal_rate
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
        dyt = DollarYenTransaction.new(date: target_date, transaction_type: transaction_type5, withdrawal_quantity: 88, address: addresses_eth)
        withdrawal_en = dyt.calculate_withdrawal_en
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


  # 　次はmakeattriburte
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
      # 初回
      it 'should be first balance_quantity when no arg.' do
        target_date = Date.new(2020, 4, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 106.59, deposit_quantity: 3.97, address: addresses_eth)
        balance_quantity = dyt.calculate_balance_quantity
        expect(balance_quantity).to eq(3.97)
      end

      # 次データなしで以前のデータもない場合
      it 'should be next balance_quantity when no prev data and no db data.' do
        target_date = Date.new(2020, 4, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 105.95, deposit_quantity: 10.76, address: addresses_eth)
        balance_quantity = dyt.calculate_balance_quantity
        expect(balance_quantity).to eq(dyt.deposit_quantity)
      end

      # 次データなしで以前のデータがある場合
      it 'should be next balance_quantity when no prev data and db data found.' do
        # 以前のデータを作成
        dollar_yen_transaction1

        target_date = Date.new(2020, 6, 19)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 105.95, deposit_quantity: 10.76, address: addresses_eth)
        balance_quantity = dyt.calculate_balance_quantity
        expect(balance_quantity).to eq(dollar_yen_transaction1.balance_quantity + dyt.deposit_quantity)
      end

      # 次データの引数あり
      it 'should be next balance_quantity.' do
        target_date = Date.new(2020, 6, 19)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 105.95, deposit_quantity: 10.76, address: addresses_eth)
        balance_quantity = dyt.calculate_balance_quantity(previous_dollar_yen_transactions: dollar_yen_transaction1)
        expect(balance_quantity).to eq(dollar_yen_transaction2.balance_quantity)
      end
    end

    context '出金の数量データを作成' do
      it 'should be balance_quantity.' do
        dollar_yen_transaction43
        target_date = Date.new(2024, 2, 1)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type5, date: target_date, withdrawal_quantity: 88, address: addresses_eth)
        balance_quantity = dyt.calculate_balance_quantity
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
      # 引数なしで以前のデータがない場合
      it 'should be first balance_quantity when no arg.' do
        target_date = Date.new(2020, 4, 1)
        dyt1 = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 106.59, deposit_quantity: 3.97, address: addresses_eth)
        balance_en = dyt1.calculate_balance_en
        expect(balance_en).to eq(dollar_yen_transaction1.balance_en)
      end

      # 引数なしで以前のデータがある場合
      it 'should be next balance_en when no prev data and db data found.' do
        # 以前のデータを作成
        dollar_yen_transaction1

        target_date = Date.new(2020, 6, 19)
        dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 105.95, deposit_quantity: 10.76, address: addresses_eth)
        balance_quantity = dyt.calculate_balance_en
        expect(balance_quantity).to eq(dollar_yen_transaction1.balance_en + dyt.calculate_deposit_en)
      end

      #  次のデータ計算(引数なし)
      it 'should be next balance_en.' do
        # 　データの実態化
        dollar_yen_transaction1
        target_date = Date.new(2020, 6, 19)
        dyt2 = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 105.95, deposit_quantity: 10.76, address: addresses_eth)
        balance_en = dyt2.calculate_balance_en
        expect(balance_en).to eq(dollar_yen_transaction2.balance_en)
      end

      # テスト(というか設計がおかしい)
      # 次データの引数あり
      # it 'should be next balance_en.' do
      #   target_date = Date.new(2020, 6, 19)
      #   dyt = DollarYenTransaction.new(transaction_type: transaction_type1, date: target_date, deposit_rate: 105.95, deposit_quantity: 10.76, address: addresses_eth)
      #   row = dyt.to_csv_import_format
      #   preload_records = { address: addresses_eth, transaction_types: addresses_eth.transaction_types }
      #   csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: -1, row: row, preload_records: preload_records)
      #   previous_dollar_yen_transactions = csv.to_dollar_yen_transaction
      #   balance_quantity = dyt.calculate_balance_en(previous_dollar_yen_transactions: previous_dollar_yen_transactions)
      #   expect(balance_quantity).to eq(dyt.calculate_balance_en)
      # end
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

  describe 'deposit_rate_on_screen' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context '画面表示 deposit_rate' do
      it 'should be deposit_rate_on_screen when data found.' do
        expect(dollar_yen_transaction1.deposit_rate_on_screen).to eq(106.59)
      end

      it 'should be deposit_rate_on_screen when data not found.' do
        expect(dollar_yen_transaction44.deposit_rate_on_screen).to be nil
      end
    end

    context '画面表示 deposit_quantity' do
      it 'should be deposit_quantity_on_screen when data found.' do
        expect(dollar_yen_transaction1.deposit_quantity_on_screen).to eq(3.97)
      end

      it 'should be deposit_quantity_on_screen when data not found.' do
        expect(dollar_yen_transaction44.deposit_quantity_on_screen).to be nil
      end
    end

    context '画面表示 deposit_en' do
      it 'should be deposit_en_screen when data found.' do
        expect(dollar_yen_transaction1.deposit_en_screen).to eq(423)
      end

      it 'should be deposit_quantity_on_screen when data not found.' do
        expect(dollar_yen_transaction44.deposit_en_screen).to be nil
      end
    end

    context '画面表示 withdrawal_rate_on_screen' do
      it 'should be withdrawal_rate_on_screen when data not found.' do
        expect(dollar_yen_transaction1.withdrawal_rate_on_screen).to be nil
      end

      it 'should be withdrawal_rate_on_screen when data found.' do
        expect(dollar_yen_transaction44.withdrawal_rate_on_screen).to eq(137.05)
      end
    end
  end

  describe 'balance_en_on_screen' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context '画面表示 balance_en_on_screen' do
      # 端数の処理は切り捨て
      it 'should be balance_en_on_screen when data is decimal point.' do
        expect(dollar_yen_transaction44.balance_en_on_screen).to eq(90166)
      end
    end
  end

  describe 'to_csv_import_format' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context 'import用のcsvデータを作成する' do
      it 'should be cvs data when deposit data.' do
        csv_data = dollar_yen_transaction1.to_csv_import_format
        expect(csv_data).to eq([ "2020/04/01", "HDV配当入金", "3.97", "106.59", nil, nil ])
      end

      it 'should be cvs data when withdrawal data.' do
        csv_data = dollar_yen_transaction44.to_csv_import_format
        expect(csv_data).to eq([ "2024/02/01", "ドルを円に変換", nil, nil, "88", "12918" ])
      end
    end
  end

  describe 'to_csv_export_format' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }

    context 'export用のcsvデータを作成する' do
      it 'should be cvs data when deposit data.' do
        csv_data = dollar_yen_transaction1.to_csv_export_format
        expect(csv_data).to eq([ "2020/04/01", "HDV配当入金", 3.97, 106.59, 423, nil, nil, nil, 3.97, 106.5491184, 423.0 ])
      end

      it 'should be cvs data when withdrawal data.' do
        csv_data = dollar_yen_transaction44.to_csv_export_format
        expect(csv_data).to eq([ "2024/02/01", "ドルを円に変換", nil, nil, nil, 88.0, 137.0555585, 12060.88915, 657.88, 137.0569101, 90166.11085 ])
      end
    end
  end

  describe 'generate_upsert_dollar_yens_transactions' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { build(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }

    context 'export用のcsvデータを作成する' do
      it 'should be cvs data when deposit data.' do
        dollar_yen_transaction1
        dollar_yen_transaction3

        dollar_yens_transactions = dollar_yen_transaction2.generate_upsert_dollar_yens_transactions()
        expect(dollar_yens_transactions.size).to eq(2)
        expect(dollar_yens_transactions[0].date).to eq(Date.new(2020, 6, 19))
        expect(dollar_yens_transactions[1].date).to eq(Date.new(2020, 9, 29))
      end
    end
  end

  # describe 'custom_date_validate' do
  #   context 'export用のcsvデータを作成する' do
  #     it 'should be cvs data when deposit data.' do
  #       dollar_yen_transaction = DollarYenTransaction.new(date: "2200/01/02")

  #       dollar_yen_transaction.custom_date_validate
  #       # dollar_yen_transaction1
  #       # dollar_yen_transaction3

  #       # dollar_yens_transactions = dollar_yen_transaction2.generate_upsert_dollar_yens_transactions()
  #       # expect(dollar_yens_transactions.size).to eq(2)
  #       # expect(dollar_yens_transactions[0].date).to eq(Date.new(2020, 6, 19))
  #       # expect(dollar_yens_transactions[1].date).to eq(Date.new(2020, 9, 29))
  #     end
  #   end
  # end
end
