require 'rails_helper'

# https://github.com/willnet/rspec-style-guide

RSpec.describe Files::DollarYenTransactionDepositCsv, type: :model do
  describe 'transaction_type_name_errors' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    it 'should get error transaction_type_nam is empty.' do
      row = [ "2020/04/01", "", "3.97", "106.59", "", "" ]
      csv = Files::DollarYenTransactionDepositCsv.new(
        address: addresses_eth,
        row_num: 2,
        row: row,
        preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
      )

      errors = []
      errors = csv.transaction_type_name_errors(errors: errors)
      expect(errors).to eq([ "2行目のtransaction_type_nameが入力されていません" ])
    end

    # 存在しないtransaction_type_nam
    it 'should get error transaction_type_nam is not found.' do
      row = [ "2020/04/01", "あいうえお", "3.97", "106.59", "", "" ]
      csv = Files::DollarYenTransactionDepositCsv.new(
        address: addresses_eth,
        row_num: 2,
        row: row,
        preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
      )

      errors = []
      errors = csv.transaction_type_name_errors(errors: errors)
      expect(errors).to eq([ "2行目のtransaction_type_nameが不正です。正しいtransaction_type_nameを入力してください" ])
    end
  end

  describe 'deposit_quantity_errors' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }


    context 'deposit' do
      # deposit_quantityがない場合
      it 'should get error deposit_quantity is empty.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "", "106.59", "", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.deposit_quantity_errors(errors: errors)
        expect(errors).to eq([ "2行目のdeposit_quantityが入力されていません" ])
      end

      # deposit_quantityがある場合
      it 'should be ok deposit_quantity is found.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.deposit_quantity_errors(errors: errors)
        expect(errors).to eq([])
      end

      context 'deposit_quantityが不正の値' do
        # deposit_quantityが不正の場合
        it 'should be [].' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "aaaa", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          csv.find_transaction_type

          errors = []
          errors = csv.deposit_quantity_errors(errors: errors)
          expect(errors).to eq([ "2行目のdeposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
        end

        # deposit_quantityが数値の場合
        it 'should be [].' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "100", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          csv.find_transaction_type

          errors = []
          errors = csv.deposit_quantity_errors(errors: errors)
          expect(errors).to eq([])
        end

        # deposit_quantityが小数点付きの数値の場合
        it 'should be [].' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          csv.find_transaction_type

          errors = []
          errors = csv.deposit_quantity_errors(errors: errors)
          expect(errors).to eq([])
        end
      end
    end

    context 'withdrawal' do
      # deposit_quantityがない場合
      it 'should be ok deposit_quantity is empty.' do
        transaction_type5
        row = [ "2024/02/01", "ドルを円に変換", "", "", "88", "12918" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth.id,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.deposit_quantity_errors(errors: errors)
        expect(errors).to eq([])
      end

      # deposit_quantityがある場合
      it 'should be ok deposit_quantity is found.' do
        transaction_type5
        row = [ "2024/02/01", "ドルを円に変換", "3.97", "", "88", "12918" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.deposit_quantity_errors(errors: errors)
        expect(errors).to eq([ "2行目のdeposit_quantityは入力できません。値を削除してください" ])
      end
    end
  end

  describe 'deposit_rate_errors' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }

    context 'deposit' do
      context 'deposit_rateがない場合' do
        it 'should be [].' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "3.97", "", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          csv.find_transaction_type

          errors = []
          errors = csv.deposit_rate_errors(errors: errors)
          expect(errors).to eq([ "2行目のdeposit_rateが入力されていません" ])
        end
      end

      context 'deposit_rateが正しい値' do
        # 　数値の場合はOK
        it 'should be [].' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "3.97", "106", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = []
          errors = csv.deposit_rate_errors(errors: errors)
          expect(errors).to eq([])
        end

        # 小数点付きの数値の場合はOK
        it 'should be [].' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = []
          errors = csv.deposit_rate_errors(errors: errors)
          expect(errors).to eq([])
        end
      end

      context 'deposit_rateが不正の値' do
        it 'should be [].' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "3.97", "bbbb", "", ""  ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          csv.find_transaction_type

          errors = []
          errors = csv.deposit_rate_errors(errors: errors)
          expect(errors).to eq([ "2行目のdeposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
        end
      end
    end

    context 'withdrawal' do
      # deposit_rateがない場合
      it 'should be ok deposit_rate is empty.' do
        transaction_type5
        row = [ "2020/04/01", "HDV配当入金", "3.97", "", "", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.deposit_rate_errors(errors: errors)
        expect(errors).to eq([])
      end

      # deposit_rateがある場合
      it 'should be ok deposit_rate is found.' do
        transaction_type5
        row = [ "2024/02/01", "ドルを円に変換", "", "106.59", "88", "12918" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.deposit_rate_errors(errors: errors)
        expect(errors).to eq([ "2行目のdeposit_rateは入力できません。値を削除してください" ])
      end
    end
  end

  describe 'withdrawal_quantity_errors' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }

    context 'withdrawal' do
      context 'withdrawal_quantityが正しい値' do
        # 　数値の場合はOK
        it 'should be [].' do
          transaction_type5
          row = [ "2024/02/01", "ドルを円に変換", "", "", "88", "12918" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          csv.find_transaction_type

          errors = []
          errors = csv.withdrawal_quantity_errors(errors: errors)
          expect(errors).to eq([])
        end

        # 小数点付きの数値の場合はOK
        it 'should be [].' do
          transaction_type5
          row = [ "2024/02/01", "ドルを円に変換", "", "", "88.34", "12918" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          csv.find_transaction_type

          errors = []
          errors = csv.withdrawal_quantity_errors(errors: errors)
          expect(errors).to eq([])
        end
      end

      context 'withdrawal_quantityが不正な値' do
        it 'should get error withdrawal_quantity is empty.' do
          transaction_type5
          row = [ "2024/02/01", "ドルを円に変換", "", "", "", "12918" ]
          csv = Files::DollarYenTransactionDepositCsv.new(
            address: addresses_eth,
            row_num: 2,
            row: row,
            preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
          )
          csv.find_transaction_type

          errors = []
          errors = csv.withdrawal_quantity_errors(errors: errors)
          expect(errors).to eq([ "2行目のwithdrawal_quantityが入力されていません" ])
        end

        it 'should get error withdrawal_quantity is string.' do
          transaction_type5
          row = [ "2024/02/01", "ドルを円に変換", "", "", "aaaaa", "12918" ]
          csv = Files::DollarYenTransactionDepositCsv.new(
            address: addresses_eth,
            row_num: 2,
            row: row,
            preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
          )
          csv.find_transaction_type

          errors = []
          errors = csv.withdrawal_quantity_errors(errors: errors)
          expect(errors).to eq([ "2行目のwithdrawal_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
        end
      end
    end

    context 'deposit' do
      # withdrawal_quantityがない場合
      it 'should be ok withdrawal_quantity is empty.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.withdrawal_quantity_errors(errors: errors)
        expect(errors).to eq([])
      end

      # withdrawal_quantityがある場合
      it 'should be ng withdrawal_quantity is found.' do
        transaction_type1
        transaction_type5
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "88", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.withdrawal_quantity_errors(errors: errors)
        expect(errors).to eq([ "2行目のwithdrawal_quantityは入力できません。値を削除してください" ])
      end
    end
  end

  describe 'exchange_en_errors' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }

    context 'withdrawal' do
      context 'exchange_enが正しい値' do
        # 　数値の場合はOK
        it 'should be [].' do
          transaction_type5
          row = [ "2024/02/01", "ドルを円に変換", "", "", "88", "12918" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          csv.find_transaction_type

          errors = []
          errors = csv.exchange_en_errors(errors: errors)
          expect(errors).to eq([])
        end

        # 小数点付きの数値の場合はOK
        it 'should be [].' do
          transaction_type5
          row = [ "2024/02/01", "ドルを円に変換", "", "", "88.34", "12918.44" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          csv.find_transaction_type

          errors = []
          errors = csv.exchange_en_errors(errors: errors)
          expect(errors).to eq([])
        end
      end

      context 'exchange_enが不正な値' do
        it 'should get error exchange_en is empty.' do
          transaction_type5
          row = [ "2024/02/01", "ドルを円に変換", "", "", "88.34", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(
            address: addresses_eth,
            row_num: 2,
            row: row,
            preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
          )
          csv.find_transaction_type

          errors = []
          errors = csv.exchange_en_errors(errors: errors)
          expect(errors).to eq([ "2行目のexchange_enが入力されていません" ])
        end

        it 'should get error exchange_en is string.' do
          transaction_type5
          row = [ "2024/02/01", "ドルを円に変換", "", "", "88.34", "aaaaa" ]
          csv = Files::DollarYenTransactionDepositCsv.new(
            address: addresses_eth,
            row_num: 2,
            row: row,
            preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
          )
          csv.find_transaction_type

          errors = []
          errors = csv.exchange_en_errors(errors: errors)
          expect(errors).to eq([ "2行目のexchange_enの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
        end
      end
    end

    context 'deposit' do
      # exchange_enがない場合
      it 'should be ok exchange_en is empty.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.exchange_en_errors(errors: errors)
        expect(errors).to eq([])
      end

      # exchange_enがある場合
      it 'should be ng exchange_en is found.' do
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "10924" ]
        csv = Files::DollarYenTransactionDepositCsv.new(
          address: addresses_eth,
          row_num: 2,
          row: row,
          preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
        )
        csv.find_transaction_type

        errors = []
        errors = csv.exchange_en_errors(errors: errors)
        expect(errors).to eq([ "2行目のexchange_enは入力できません。値を削除してください" ])
      end
    end
  end

  describe 'valid_errors' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    context 'deposit' do
      context 'エラーがない場合' do
        it 'should be [].' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(
            address: addresses_eth,
            row_num: 2,
            row: row,
            preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) }
          )
          csv.find_transaction_type

          errors = csv.valid_errors
          expect(errors).to eq([])
        end
      end

      context '日付エラー' do
        it 'should be error when date is empty.' do
          transaction_type1
          row = [ "", "HDV配当入金", "3.97", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "2行目のdateが入力されていません" ])
        end

        it 'should be error when date is invalid format.' do
          transaction_type1
          row = [ "2020-04-01", "HDV配当入金", "3.97", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "2行目のdateのフォーマットが不正です。yyyy/mm/dd形式で入力してください" ])
        end

        it 'should be error when date is invalid date.' do
          transaction_type1
          row = [ "2020/04/33", "HDV配当入金", "3.97", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "2行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ])
        end

        it 'should be error when date is invalid date2.' do
          transaction_type1
          row = [ "aaaa/bb/cc", "HDV配当入金", "3.97", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "2行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ])
        end
      end

      context 'transaction_type_nameエラー' do
        it 'should be error when transaction_type_name is empty.' do
          transaction_type1
          row = [ "2020/04/01", "", "3.97", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "2行目のtransaction_type_nameが入力されていません" ])
        end

        it 'should be error when transaction_type_name is error.' do
          row = [ "2020/04/01", "SPA配当入金", "3.97", "106.59", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "2行目のtransaction_type_nameが不正です。正しいtransaction_type_nameを入力してください" ])
        end
      end

      context 'deposit_quantityエラー' do
        it 'should be error when deposit_quantity is empty.' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "", "106.59", "", ""  ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "2行目のdeposit_quantityが入力されていません" ])
        end

        it 'should be error when deposit_quantity is invalid.' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "aaa", "106.59", "", ""  ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 3, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "3行目のdeposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
        end
      end

      context 'deposit_quantityエラー' do
        it 'should be error when deposit_rate is empty.' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "10", "", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "2行目のdeposit_rateが入力されていません" ])
        end

        it 'should be error when deposit_rate is invalid.' do
          transaction_type1
          row = [ "2020/04/01", "HDV配当入金", "10", "cccc", "", "" ]
          csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 3, row: row)
          errors = csv.valid_errors
          expect(errors).to eq([ "3行目のdeposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
        end
      end
    end
  end

  describe 'unique_key' do
    let(:addresses_eth) { create(:addresses_eth) }

    it 'should get unique_key.' do
      row = [ "2020/04/01", "HDV配当入金", "10", "", "", "" ]
      csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
      expect(csv.unique_key).to eq("2020/04/01-HDV配当入金")
    end
  end

  describe 'unique_key_hash' do
    let(:addresses_eth) { create(:addresses_eth) }
    it 'should get unique_key_hash.' do
      h = {}
      row = [ "2020/04/01", "HDV配当入金", "10", "", "", "" ]
      csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
      h = csv.unique_key_hash(unique_key_hash: h)
      csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 4, row: row)
      h = csv.unique_key_hash(unique_key_hash: h)

      expect(h).to eq({ "2020/04/01-HDV配当入金"=>{ rownums: [ 2, 4 ] } })
    end
  end

  describe 'target_date' do
    let(:addresses_eth) { create(:addresses_eth) }
    it 'should get target_date of Date Type.' do
      row = [ "2020/04/01", "HDV配当入金", "10", "", "", "" ]
      csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)

      expect(csv.target_date).to eq(Date.new(2020, 4, 1))
    end
  end

  describe 'to_dollar_yen_transaction' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }

    context 'deposit' do
      # 　初回データ
      it 'should get first data.' do
        # transaction_type1の実体化
        transaction_type1
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
        csv.find_transaction_type

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
        data_row1 = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
        data_row2 = [ "2020/06/19", "HDV配当入金", "10.76", "105.95", "", "" ]
        csv_line1 = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: data_row1)
        csv_line1.find_transaction_type
        dollar_yen_transaction1 = csv_line1.to_dollar_yen_transaction
        csv_line2 = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 3, row: data_row2)
        csv_line2.find_transaction_type
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

    context 'deposit and withdrawal' do
      it 'should get withdrawal data.' do
        transaction_type1
        transaction_type5
        row = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
        row2 = [ "2020/06/19", "ドルを円に変換", "", "", "2", "250" ]
        csv_line1 = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: row)
        csv_line1.find_transaction_type
        calc_dollar_yen_transaction1 = csv_line1.to_dollar_yen_transaction
        csv_line2 = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 3, row: row2)
        csv_line2.find_transaction_type
        calc_dollar_yen_transaction2 = csv_line2.to_dollar_yen_transaction(previous_dollar_yen_transactions: dollar_yen_transaction1)

        expect(calc_dollar_yen_transaction1.transaction_type).to eq(transaction_type1)
        expect(calc_dollar_yen_transaction1.date).to eq(Date.new(2020, 4, 1))
        expect(calc_dollar_yen_transaction1.deposit_rate).to eq(dollar_yen_transaction1.deposit_rate)
        expect(calc_dollar_yen_transaction1.deposit_quantity).to eq(dollar_yen_transaction1.deposit_quantity)
        expect(calc_dollar_yen_transaction1.deposit_en).to eq(dollar_yen_transaction1.deposit_en)
        expect(calc_dollar_yen_transaction1.balance_rate.truncate(6)).to eq(dollar_yen_transaction1.balance_rate.truncate(6))
        expect(calc_dollar_yen_transaction1.balance_quantity.truncate(6)).to eq(dollar_yen_transaction1.balance_quantity.truncate(6))
        expect(calc_dollar_yen_transaction1.balance_en.truncate(6)).to eq(dollar_yen_transaction1.balance_en.truncate(6))

        expect(calc_dollar_yen_transaction2.transaction_type).to eq(transaction_type5)
        expect(calc_dollar_yen_transaction2.date).to eq(Date.new(2020, 6, 19))
        expect(calc_dollar_yen_transaction2.deposit_rate).to be nil
        expect(calc_dollar_yen_transaction2.deposit_quantity).to be nil
        expect(calc_dollar_yen_transaction2.deposit_en).to be nil
        expect(calc_dollar_yen_transaction2.withdrawal_rate.truncate(7).to_f).to eq(106.5491184)
        expect(calc_dollar_yen_transaction2.withdrawal_quantity).to eq(2)
        expect(calc_dollar_yen_transaction2.withdrawal_en.truncate(7).to_f).to eq(213.0982368)
        expect(calc_dollar_yen_transaction2.exchange_en).to eq(250)
        expect(calc_dollar_yen_transaction2.exchange_difference.truncate(7).to_f).to eq(36.9017632)
      end
    end
  end

  describe 'find_transaction_type' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

    # transactionが空の場合はnil
    it 'should get nil when transaction is empty.' do
      data_row1 = [ "2020/04/01", "", "3.97", "106.59", "", "" ]
      csv_line1 = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: data_row1)

      expect(csv_line1.find_transaction_type).to be nil
    end

    # transactionがあって、キャッシュがない場合
    it 'should get nil when transaction is found and no cache.' do
      transaction_type1
      data_row1 = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
      csv_line1 = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: data_row1)

      csv_line1.find_transaction_type
      expect(csv_line1.transaction_type).to eq(transaction_type1)
    end

    # transactionがあって、キャッシュがある場合
    it 'should get nil when transaction is found and found cache.' do
      transaction_type1
      data_row1 = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
      csv_line1 = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: data_row1, preload_records: { transaction_types: TransactionType.where(address_id: addresses_eth.id) })
      csv_line1.find_transaction_type

      expect(csv_line1.transaction_type).to eq(transaction_type1)
    end
  end

  describe 'create_dollar_yen_transaction' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, address: addresses_eth, transaction_type: transaction_type1) }

    context '既存データなし' do
      it "should be new dollar_yen_transaction object" do
        transaction_type1

        data_row1 = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: data_row1)
        dollar_yen_transaction = csv.create_dollar_yen_transaction

        # idは存在しない
        expect(dollar_yen_transaction.id).to be nil
        expect(dollar_yen_transaction.date).to eq(Date.new(2020, 4, 1))
        expect(dollar_yen_transaction.transaction_type).to eq(transaction_type1)
      end
    end

    context '既存データあり' do
      it "should be get dollar_yen_transaction object" do
        dollar_yen_transaction1

        data_row1 = [ "2020/04/01", "HDV配当入金", "3.97", "106.59", "", "" ]
        csv = Files::DollarYenTransactionDepositCsv.new(address: addresses_eth, row_num: 2, row: data_row1)
        dollar_yen_transaction = csv.create_dollar_yen_transaction

        # idは存在しない
        expect(dollar_yen_transaction.id).to eq(dollar_yen_transaction1.id)
        expect(dollar_yen_transaction).to eq(dollar_yen_transaction1)
      end
    end
  end


  describe 'make_dollar_yen_transactions' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:deposit_three_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_three_csv.csv" }
    let(:deposit_and_withdrawal_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_and_withdrawal.csv" }
    let(:job_2) { create(:job_2) }
    let(:import_file) { create(:import_file, address: addresses_eth, job: job_2) }
    let(:deposit_series_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_csv.csv" }
    let(:deposit_series_1_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_1.csv" }
    let(:deposit_series_2_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_2.csv" }


    context 'make_dollar_yen_transactions' do
      # 3行分のデータを作成して確認
      it 'should get dollar_yen_transactions.' do
        transaction_type1

        file = File.new(deposit_three_csv_path)
        import_file.file.attach(file)
        import_file.save

        csvs = import_file.make_csvs_dollar_yens_transactions
        dollar_yen_transactions = Files::DollarYenTransactionDepositCsv.make_dollar_yen_transactions(csvs: csvs)

        expect(dollar_yen_transactions.size).to eq(3)
        data1 = dollar_yen_transactions[0]
        data2 = dollar_yen_transactions[1]
        data3 = dollar_yen_transactions[2]
        # 1行目
        expect(data1.transaction_type).to eq(transaction_type1)
        expect(data1.date).to eq(dollar_yen_transaction1.date)
        expect(data1.deposit_rate).to eq(dollar_yen_transaction1.deposit_rate)
        expect(data1.deposit_quantity).to eq(dollar_yen_transaction1.deposit_quantity)
        expect(data1.deposit_en).to eq(dollar_yen_transaction1.deposit_en)
        expect(data1.balance_rate.truncate(6)).to eq(dollar_yen_transaction1.balance_rate.truncate(6))
        expect(data1.balance_quantity.truncate(6)).to eq(dollar_yen_transaction1.balance_quantity.truncate(6))
        expect(data1.balance_en.truncate(6)).to eq(dollar_yen_transaction1.balance_en.truncate(6))
        # 2行目
        expect(data2.transaction_type).to eq(transaction_type1)
        expect(data2.date).to eq(dollar_yen_transaction2.date)
        expect(data2.deposit_rate).to eq(dollar_yen_transaction2.deposit_rate)
        expect(data2.deposit_quantity).to eq(dollar_yen_transaction2.deposit_quantity)
        expect(data2.deposit_en).to eq(dollar_yen_transaction2.deposit_en)
        expect(data2.balance_rate.truncate(6)).to eq(dollar_yen_transaction2.balance_rate.truncate(6))
        expect(data2.balance_quantity.truncate(6)).to eq(dollar_yen_transaction2.balance_quantity.truncate(6))
        expect(data2.balance_en.truncate(6)).to eq(dollar_yen_transaction2.balance_en.truncate(6))
        # ３行目
        expect(data3.transaction_type).to eq(transaction_type1)
        expect(data3.date).to eq(dollar_yen_transaction3.date)
        expect(data3.deposit_rate).to eq(dollar_yen_transaction3.deposit_rate)
        expect(data3.deposit_quantity).to eq(dollar_yen_transaction3.deposit_quantity)
        expect(data3.deposit_en).to eq(dollar_yen_transaction3.deposit_en)
        expect(data3.balance_rate.truncate(6)).to eq(dollar_yen_transaction3.balance_rate.truncate(6))
        expect(data3.balance_quantity.truncate(6)).to eq(dollar_yen_transaction3.balance_quantity.truncate(6))
        expect(data3.balance_en.truncate(6)).to eq(dollar_yen_transaction3.balance_en.truncate(6))

        import_file.file.purge
        FileUtils.rm_rf(ActiveStorage::Blob.service.root)
      end

      # 両方
      it 'should get dollar_yen_transactions when deposit and withdrawal.' do
        transaction_type1
        transaction_type5

        file = File.new(deposit_and_withdrawal_csv_path)
        import_file.file.attach(file)
        import_file.save

        csvs = import_file.make_csvs_dollar_yens_transactions
        dollar_yen_transactions = Files::DollarYenTransactionDepositCsv.make_dollar_yen_transactions(csvs: csvs)

        expect(dollar_yen_transactions.size).to eq(4)

        data1 = dollar_yen_transactions[0]
        data2 = dollar_yen_transactions[1]
        data3 = dollar_yen_transactions[2]
        data4 = dollar_yen_transactions[3]

        # 1行目
        expect(data1.transaction_type).to eq(transaction_type1)
        expect(data1.date).to eq(dollar_yen_transaction1.date)
        expect(data1.deposit_rate).to eq(dollar_yen_transaction1.deposit_rate)
        expect(data1.deposit_quantity).to eq(dollar_yen_transaction1.deposit_quantity)
        expect(data1.deposit_en).to eq(dollar_yen_transaction1.deposit_en)
        expect(data1.balance_rate.truncate(6)).to eq(dollar_yen_transaction1.balance_rate.truncate(6))
        expect(data1.balance_quantity.truncate(6)).to eq(dollar_yen_transaction1.balance_quantity.truncate(6))
        expect(data1.balance_en.truncate(6)).to eq(dollar_yen_transaction1.balance_en.truncate(6))

        # TODO 2行目以降のチェック
        import_file.file.purge
        FileUtils.rm_rf(ActiveStorage::Blob.service.root)
      end
    end
  end
end
