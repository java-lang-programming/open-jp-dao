require 'rails_helper'

RSpec.describe DollarYenTransactionsUpdateJob, type: :job do
  describe 'create data確認' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type3) { create(:transaction_type3, address: addresses_eth) }
    let(:transaction_type4) { create(:transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1_same_day) { create(:dollar_yen_transaction1, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_1) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_2) { create(:dollar_yen_transaction2, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_3) { create(:dollar_yen_transaction2, transaction_type: transaction_type3, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_4) { create(:dollar_yen_transaction2, transaction_type: transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction4) { create(:dollar_yen_transaction4, transaction_type: transaction_type1, address: addresses_eth) }
    let(:master_export_master_csv_path) { "#{Rails.root}/spec/files/dollar_yen_transactions/master_export.csv" }

    # 日付データの重複なしでの途中追加
    it 'should be success when data is added.' do
      dollar_yen_transaction1
      dollar_yen_transaction3
      dollar_yen_transaction4

      # 2番目のデータを通過
      dollar_yen_transaction = DollarYenTransaction.new
      date = Date.new(2020, 6, 19)
      dollar_yen_transaction.date = date
      dollar_yen_transaction.address = addresses_eth
      dollar_yen_transaction.transaction_type = transaction_type1
      dollar_yen_transaction.deposit_quantity = BigDecimal("10.76")
      dollar_yen_transaction.deposit_rate = BigDecimal("105.95")

      # 作成&upsert
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction, kind: DollarYenTransaction::KIND_CREATE)

      created = addresses_eth.dollar_yen_transactions.order(date: :asc).order(date: :asc).order(id: :asc)

      future_gadgets = CSV.read(master_export_master_csv_path)
      row_index = 0
      expects = []
      future_gadgets.each do |fg|
        row_index = row_index + 1
        next if row_index == 1
        csv = Files::DollarYenTransactionExportCsv.new(row: fg)
        expects << csv.line_to_s
      end

      expect(expects[0]).to eq(created[0].to_csv_export_format.join(','))
      expect(expects[1]).to eq(created[1].to_csv_export_format.join(','))
      expect(expects[2]).to eq(created[2].to_csv_export_format.join(','))
      expect(expects[3]).to eq(created[3].to_csv_export_format.join(','))
    end

    # 日付が重なるパターン
    it 'should be success when date is same.' do
      dollar_yen_transaction1 = build(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth)
      dollar_yen_transaction1.date = Date.new(2020, 6, 19)
      dollar_yen_transaction1.save
      dollar_yen_transaction2 = build(:dollar_yen_transaction2, transaction_type: transaction_type2, address: addresses_eth)
      dollar_yen_transaction2.date = Date.new(2020, 6, 19)
      dollar_yen_transaction2.save

      # 3番目のデータを通過
      dollar_yen_transaction = DollarYenTransaction.new
      date = Date.new(2020, 6, 19)
      dollar_yen_transaction.date = date
      dollar_yen_transaction.address = addresses_eth
      dollar_yen_transaction.transaction_type = transaction_type3
      dollar_yen_transaction.deposit_quantity = BigDecimal("14.73")
      dollar_yen_transaction.deposit_rate = BigDecimal("104.35")

      # 作成&upsert
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction, kind: DollarYenTransaction::KIND_CREATE)

      created = addresses_eth.dollar_yen_transactions.order(date: :asc).order(date: :asc).order(id: :asc)

      future_gadgets = CSV.read(master_export_master_csv_path)
      row_index = 0
      expects = []
      future_gadgets.each do |fg|
        row_index = row_index + 1
        next if row_index == 1
        csv = Files::DollarYenTransactionExportCsv.new(row: fg)
        csv.replace_date(date: "2020/06/19")
        csv.replace_transaction_type_name(transaction_type_name: transaction_type2.name) if row_index == 3
        csv.replace_transaction_type_name(transaction_type_name: transaction_type3.name) if row_index == 4
        expects << csv.line_to_s
      end

      expect(expects[0]).to eq(created[0].to_csv_export_format.join(','))
      expect(expects[1]).to eq(created[1].to_csv_export_format.join(','))
      expect(expects[2]).to eq(created[2].to_csv_export_format.join(','))
    end

    # 他のデータを作成後、最初のデータを作成する
    it 'should be success when first data is create.' do
      dollar_yen_transaction2_same_day_1
      dollar_yen_transaction3
      dollar_yen_transaction4

      # 1番目のデータを通過
      dollar_yen_transaction = DollarYenTransaction.new
      date = Date.new(2020, 4, 1)
      dollar_yen_transaction.date = date
      dollar_yen_transaction.address = addresses_eth
      dollar_yen_transaction.transaction_type = transaction_type1
      dollar_yen_transaction.deposit_quantity = BigDecimal("3.97")
      dollar_yen_transaction.deposit_rate = BigDecimal("106.59")

      # 作成&upsert
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction, kind: DollarYenTransaction::KIND_CREATE)

      created = addresses_eth.dollar_yen_transactions.order(date: :asc).order(date: :asc).order(id: :asc)

      future_gadgets = CSV.read(master_export_master_csv_path)
      row_index = 0
      expects = []
      future_gadgets.each do |fg|
        row_index = row_index + 1
        next if row_index == 1
        csv = Files::DollarYenTransactionExportCsv.new(row: fg)
        expects << csv.line_to_s
      end

      expect(expects[0]).to eq(created[0].to_csv_export_format.join(','))
      expect(expects[1]).to eq(created[1].to_csv_export_format.join(','))
      expect(expects[2]).to eq(created[2].to_csv_export_format.join(','))
      expect(expects[3]).to eq(created[3].to_csv_export_format.join(','))
    end
  end

  describe 'update data確認' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type3) { create(:transaction_type3, address: addresses_eth) }
    let(:transaction_type4) { create(:transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1_same_day) { create(:dollar_yen_transaction1, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_1) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_2) { create(:dollar_yen_transaction2, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_3) { create(:dollar_yen_transaction2, transaction_type: transaction_type3, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_4) { create(:dollar_yen_transaction2, transaction_type: transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction4) { create(:dollar_yen_transaction4, transaction_type: transaction_type1, address: addresses_eth) }
    let(:master_export_master_csv_path) { "#{Rails.root}/spec/files/dollar_yen_transactions/master_export.csv" }

    # 日付データの重複なしでの途中更新
    it 'should be success when data is updated.' do
      dollar_yen_transaction1
      dollar_yen_transaction2_same_day_1
      dollar_yen_transaction2_same_day_1.deposit_quantity = BigDecimal("10")
      dollar_yen_transaction2_same_day_1.deposit_rate = BigDecimal("100")
      dollar_yen_transaction2_same_day_1.deposit_en = BigDecimal("1000")
      dollar_yen_transaction2_same_day_1.save
      dollar_yen_transaction3
      dollar_yen_transaction4


      # 2番目のデータを更新
      dollar_yen_transaction2_same_day_1.deposit_quantity = BigDecimal("10.76")
      dollar_yen_transaction2_same_day_1.deposit_rate = BigDecimal("105.95")
      dollar_yen_transaction2_same_day_1.save

      # 更新&upsert
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction2_same_day_1, kind: DollarYenTransaction::KIND_UPDATE)

      updated = addresses_eth.dollar_yen_transactions.order(date: :asc).order(date: :asc).order(id: :asc)

      future_gadgets = CSV.read(master_export_master_csv_path)
      row_index = 0
      expects = []
      future_gadgets.each do |fg|
        row_index = row_index + 1
        next if row_index == 1
        csv = Files::DollarYenTransactionExportCsv.new(row: fg)
        expects << csv.line_to_s
      end

      expect(expects[0]).to eq(updated[0].to_csv_export_format.join(','))
      expect(expects[1]).to eq(updated[1].to_csv_export_format.join(','))
      expect(expects[2]).to eq(updated[2].to_csv_export_format.join(','))
      expect(expects[3]).to eq(updated[3].to_csv_export_format.join(','))
    end

    # 日付が重なるパターン
    it 'should be success when date is same.' do
      dollar_yen_transaction1
      dollar_yen_transaction2_same_day_1
      dollar_yen_transaction2_same_day_1.date = Date.new(2020, 4, 1)
      dollar_yen_transaction2_same_day_1.transaction_type = transaction_type2
      dollar_yen_transaction2_same_day_1.deposit_quantity = BigDecimal("10")
      dollar_yen_transaction2_same_day_1.deposit_rate = BigDecimal("100")
      dollar_yen_transaction2_same_day_1.deposit_en = BigDecimal("1000")
      dollar_yen_transaction2_same_day_1.save
      dollar_yen_transaction3
      dollar_yen_transaction3.date = Date.new(2020, 4, 1)
      dollar_yen_transaction3.transaction_type = transaction_type3
      dollar_yen_transaction3.save
      dollar_yen_transaction4
      dollar_yen_transaction4.date = Date.new(2020, 4, 1)
      dollar_yen_transaction4.transaction_type = transaction_type4
      dollar_yen_transaction4.save

      # 2番目のデータを更新
      dollar_yen_transaction2_same_day_1.deposit_quantity = BigDecimal("10.76")
      dollar_yen_transaction2_same_day_1.deposit_rate = BigDecimal("105.95")
      dollar_yen_transaction2_same_day_1.save

      # 更新&upsert
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction2_same_day_1, kind: DollarYenTransaction::KIND_UPDATE)

      updated = addresses_eth.dollar_yen_transactions.order(date: :asc).order(date: :asc).order(id: :asc)

      future_gadgets = CSV.read(master_export_master_csv_path)
      row_index = 0
      expects = []
      future_gadgets.each do |fg|
        row_index = row_index + 1
        next if row_index == 1
        csv = Files::DollarYenTransactionExportCsv.new(row: fg)
        csv.replace_date(date: "2020/04/01")
        csv.replace_transaction_type_name(transaction_type_name: transaction_type2.name) if row_index == 3
        csv.replace_transaction_type_name(transaction_type_name: transaction_type3.name) if row_index == 4
        csv.replace_transaction_type_name(transaction_type_name: transaction_type4.name) if row_index == 5
        expects << csv.line_to_s
      end

      expect(expects[0]).to eq(updated[0].to_csv_export_format.join(','))
      expect(expects[1]).to eq(updated[1].to_csv_export_format.join(','))
      expect(expects[2]).to eq(updated[2].to_csv_export_format.join(','))
      expect(expects[3]).to eq(updated[3].to_csv_export_format.join(','))
    end

    # 他のデータを作成後、最初のデータを更新する
    it 'should be success when data is updated.' do
      dollar_yen_transaction1
      dollar_yen_transaction1.deposit_quantity = BigDecimal("10")
      dollar_yen_transaction1.deposit_rate = BigDecimal("100")
      dollar_yen_transaction1.deposit_en = BigDecimal("1000")
      dollar_yen_transaction1.save
      dollar_yen_transaction2_same_day_1
      dollar_yen_transaction3
      dollar_yen_transaction4

      # 2番目のデータを更新
      dollar_yen_transaction1.deposit_quantity = BigDecimal("3.97")
      dollar_yen_transaction1.deposit_rate = BigDecimal("106.59")
      dollar_yen_transaction1.save

      # 更新&upsert
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction1, kind: DollarYenTransaction::KIND_UPDATE)

      updated = addresses_eth.dollar_yen_transactions.order(date: :asc).order(date: :asc).order(id: :asc)

      future_gadgets = CSV.read(master_export_master_csv_path)
      row_index = 0
      expects = []
      future_gadgets.each do |fg|
        row_index = row_index + 1
        next if row_index == 1
        csv = Files::DollarYenTransactionExportCsv.new(row: fg)
        expects << csv.line_to_s
      end

      expect(expects[0]).to eq(updated[0].to_csv_export_format.join(','))
      expect(expects[1]).to eq(updated[1].to_csv_export_format.join(','))
      expect(expects[2]).to eq(updated[2].to_csv_export_format.join(','))
      expect(expects[3]).to eq(updated[3].to_csv_export_format.join(','))
    end
  end

  # https://qiita.com/necojackarc/items/b4a8ac682efeb1f62e74
  # リトライ


  # 値の確認
end
