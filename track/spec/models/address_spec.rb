require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'matamask_format_address' do
    let(:addresses_eth) { create(:addresses_eth) }

    context 'matamaskのaddress形式で返す' do
      it 'should be get matamask address format.' do
        expect(addresses_eth.matamask_format_address).to eq('0x00001...CC89D')
      end
    end
  end

  describe 'generate_dollar_yen_transactions_csv_import_file' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_2) { create(:job_2) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:import_file) { create(:import_file, job: job_2, address: addresses_eth) }
    let(:deposit_series_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_csv.csv" }

    context 'csv_import_fileを作成' do
      # 1回import
      it 'should be create csv when DollarYenTransactionsCsvImportJob is performed.' do
        transaction_type1
        transaction_type2

        output_csv_file_path = "#{Rails.root}/tmp/storage/result.csv"

        file = File.new(deposit_series_csv_path)
        import_file.file.attach(file)
        import_file.save

        # 最初の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
        import_file.file.purge

        addresses_eth.generate_dollar_yen_transactions_csv_import_file(output_csv_file_path: output_csv_file_path)

        original_csvs = []
        CSV.foreach(deposit_series_csv_path) do |fg|
          original_csvs << fg
        end

        created_csvs = []
        CSV.foreach(output_csv_file_path) do |fg|
          created_csvs << fg
        end

        expect(original_csvs == created_csvs).to be true

        import_file.file.purge
        FileUtils.rm_rf(output_csv_file_path)
      end
    end
  end

  describe 'generate_dollar_yen_transactions_csv_export_import_file' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:job_2) { create(:job_2) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:import_file) { create(:import_file, job: job_2, address: addresses_eth) }
    let(:deposit_series_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_csv.csv" }
    let(:deposit_series_1_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_1.csv" }
    let(:deposit_series_2_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/deposit_series_2.csv" }
    let(:deposit_series_csv_export_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/export/deposit_series_csv_export.csv" }

    context 'csv_import_fileを作成' do
      # 1回import
      it 'should be create csv when DollarYenTransactionsCsvImportJob is performed.' do
        transaction_type1
        transaction_type2

        output_csv_file_path = "#{Rails.root}/tmp/storage/result.csv"

        file = File.new(deposit_series_csv_path)
        import_file.file.attach(file)
        import_file.save

        # 最初の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
        import_file.file.purge

        addresses_eth.generate_dollar_yen_transactions_csv_export_import_file(output_csv_file_path: output_csv_file_path)

        export_original_csvs = []
        CSV.foreach(deposit_series_csv_export_path) do |fg|
          export_original_csvs << fg
        end

        created_csvs = []
        CSV.foreach(output_csv_file_path) do |fg|
          created_csvs << fg
        end

        expect(export_original_csvs == created_csvs).to be true

        FileUtils.rm_rf(output_csv_file_path)
      end

      # 2回目import
      # 2回目は1回目で抜けていたデータを保管する
      it 'should be create csv when DollarYenTransactionsCsvImportJob is performed twice.' do
        transaction_type1
        transaction_type2

        file = File.new(deposit_series_1_csv_path)
        import_file.file.attach(file)
        import_file.save

        # 最初の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file.id)
        import_file.file.purge

        import_file2 = create(:import_file, job: job_2, address: addresses_eth)
        file2 = File.new(deposit_series_2_csv_path)
        import_file2.file.attach(file2)
        import_file2.save

        # 2回目の登録
        DollarYenTransactionsCsvImportJob.perform_now(import_file_id: import_file2.id)
        import_file2.file.purge

        output_csv_file_path = "#{Rails.root}/tmp/storage/result.csv"
        addresses_eth.generate_dollar_yen_transactions_csv_export_import_file(output_csv_file_path: output_csv_file_path)

        export_original_csvs = []
        CSV.foreach(deposit_series_csv_export_path) do |fg|
          export_original_csvs << fg
        end

        created_csvs = []
        CSV.foreach(output_csv_file_path) do |fg|
          created_csvs << fg
        end

        expect(export_original_csvs == created_csvs).to be true

        FileUtils.rm_rf(output_csv_file_path)
      end
    end
  end

  describe 'make_file_name' do
    let(:addresses_eth) { create(:addresses_eth) }

    context 'file_pathを作成' do
      it 'should be file_name.' do
        file_name = addresses_eth.make_file_name
        expect(file_name).to match(/#{addresses_eth.address}/)
      end
    end
  end

  describe 'recalculation_need_dollar_yen_transactions_create' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type3) { create(:transaction_type3, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day) { create(:dollar_yen_transaction2, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_2) { create(:dollar_yen_transaction2, transaction_type: transaction_type3, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }

    context '既存データがない場合' do
      it 'should be 0.' do
        target_date = "2020-12-18"
        dollar_yen_transactions = addresses_eth.recalculation_need_dollar_yen_transactions_create(target_date: target_date)
        expect(dollar_yen_transactions.count).to eq(0)
      end
    end

    context '既存データがある場合' do
      # target_dateより新しいデータがない場合(最新の場合)
      it 'should be 0.' do
        dollar_yen_transaction1
        dollar_yen_transaction2
        dollar_yen_transaction3

        target_date = "2020-12-18"
        dollar_yen_transactions = addresses_eth.recalculation_need_dollar_yen_transactions_create(target_date: target_date)
        expect(dollar_yen_transactions.count).to eq(0)
      end

      # dollar_yen_transaction2とdollar_yen_transaction3の間の日付
      it 'should be 1.' do
        dollar_yen_transaction1
        dollar_yen_transaction2
        # 　ここの間
        dollar_yen_transaction3

        target_date = "2020-09-28"
        dollar_yen_transactions = addresses_eth.recalculation_need_dollar_yen_transactions_create(target_date: target_date)
        expect(dollar_yen_transactions.count).to eq(1)
      end

      # dollar_yen_transaction2と同じ日付(境界データ)
      # 既存データの間に入れる
      it 'should be 1.' do
        dollar_yen_transaction1
        # これと同じ日付
        dollar_yen_transaction2
        dollar_yen_transaction3

        target_date = "2020-06-19"
        dollar_yen_transactions = addresses_eth.recalculation_need_dollar_yen_transactions_create(target_date: target_date)
        expect(dollar_yen_transactions.count).to eq(1)
      end
    end
  end

  describe 'recalculation_need_dollar_yen_transactions_delete' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type3) { create(:transaction_type3, address: addresses_eth) }
    let(:transaction_type4) { create(:transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_1) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_2) { create(:dollar_yen_transaction2, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_3) { create(:dollar_yen_transaction2, transaction_type: transaction_type3, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_4) { create(:dollar_yen_transaction2, transaction_type: transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction3_2) { create(:dollar_yen_transaction3, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction4) { create(:dollar_yen_transaction4, transaction_type: transaction_type1, address: addresses_eth) }

    context '削除データ以外の既存データがない' do
      it 'should get recalculation dollar_yen_transactions for delete.' do
        dollar_yen_transaction1

        recalculation_need_dollar_yen_transactions_delete = addresses_eth.recalculation_need_dollar_yen_transactions_delete(target_date: dollar_yen_transaction1.date, id: dollar_yen_transaction1.id)
        expect(recalculation_need_dollar_yen_transactions_delete.size).to eq(0)
      end
    end

    context '既存データがある' do
      # 　削除によって再計算が必要なデータを取得する
      # 　条件: 同じ日のトランザジュションデータがある
      #       同じ日以外にも変更必要な取引データがある
      it 'should get recalculation dollar_yen_transactions for delete.' do
        dollar_yen_transaction1
        dollar_yen_transaction2_same_day_1
        dollar_yen_transaction2_same_day_2
        # 　これを削除予定
        dollar_yen_transaction2_same_day_3
        dollar_yen_transaction2_same_day_4
        dollar_yen_transaction3
        dollar_yen_transaction3_2
        dollar_yen_transaction4

        recalculation_need_dollar_yen_transactions_delete = addresses_eth.recalculation_need_dollar_yen_transactions_delete(target_date: dollar_yen_transaction2_same_day_3.date, id: dollar_yen_transaction2_same_day_3.id)
        expect(recalculation_need_dollar_yen_transactions_delete.size).to eq(4)

        expect(recalculation_need_dollar_yen_transactions_delete[0].id).to eq(dollar_yen_transaction2_same_day_4.id)
        expect(recalculation_need_dollar_yen_transactions_delete[0].date).to eq(dollar_yen_transaction2_same_day_4.date)
        expect(recalculation_need_dollar_yen_transactions_delete[1].id).to eq(dollar_yen_transaction3.id)
        expect(recalculation_need_dollar_yen_transactions_delete[1].date).to eq(dollar_yen_transaction3.date)
        expect(recalculation_need_dollar_yen_transactions_delete[2].id).to eq(dollar_yen_transaction3_2.id)
        expect(recalculation_need_dollar_yen_transactions_delete[2].date).to eq(dollar_yen_transaction3_2.date)
        expect(recalculation_need_dollar_yen_transactions_delete[3].id).to eq(dollar_yen_transaction4.id)
        expect(recalculation_need_dollar_yen_transactions_delete[3].date).to eq(dollar_yen_transaction4.date)
      end

      # 　削除によって再計算が必要なデータを取得する
      # 　条件: 同じ日のトランザジュションデータがある
      #       削除データが最新の日付データ&IDである
      it 'should get recalculation dollar_yen_transactions for delete.' do
        dollar_yen_transaction1
        dollar_yen_transaction2_same_day_1
        dollar_yen_transaction2_same_day_2
        # 　これを削除予定
        dollar_yen_transaction2_same_day_3

        recalculation_need_dollar_yen_transactions_delete = addresses_eth.recalculation_need_dollar_yen_transactions_delete(target_date: dollar_yen_transaction2_same_day_3.date, id: dollar_yen_transaction2_same_day_3.id)
        expect(recalculation_need_dollar_yen_transactions_delete.size).to eq(0)
      end
    end
  end

  describe 'recalculation_need_dollar_yen_transactions_update' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type3) { create(:transaction_type3, address: addresses_eth) }
    let(:transaction_type4) { create(:transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_1) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_2) { create(:dollar_yen_transaction2, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_3) { create(:dollar_yen_transaction2, transaction_type: transaction_type3, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_4) { create(:dollar_yen_transaction2, transaction_type: transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction3_2) { create(:dollar_yen_transaction3, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction4) { create(:dollar_yen_transaction4, transaction_type: transaction_type1, address: addresses_eth) }

    context '更新データ以外の既存データがない' do
      it 'should get recalculation dollar_yen_transactions for 更新.' do
        dollar_yen_transaction1

        recalculation_need_dollar_yen_transactions_update = addresses_eth.recalculation_need_dollar_yen_transactions_update(target_date: dollar_yen_transaction1.date, id: dollar_yen_transaction1.id)
        expect(recalculation_need_dollar_yen_transactions_update.size).to eq(0)
      end
    end

    context '既存データがある' do
      # 　更新によって再計算が必要なデータを取得する
      # 　条件: 同じ日のトランザジュションデータがある
      #       同じ日以外にも変更必要な取引データがある
      it 'should get recalculation dollar_yen_transactions for update.' do
        dollar_yen_transaction1
        dollar_yen_transaction2_same_day_1
        dollar_yen_transaction2_same_day_2
        # 　これを削除予定
        dollar_yen_transaction2_same_day_3
        dollar_yen_transaction2_same_day_4
        dollar_yen_transaction3
        dollar_yen_transaction3_2
        dollar_yen_transaction4

        recalculation_need_dollar_yen_transactions_update = addresses_eth.recalculation_need_dollar_yen_transactions_update(target_date: dollar_yen_transaction2_same_day_3.date, id: dollar_yen_transaction2_same_day_3.id)
        expect(recalculation_need_dollar_yen_transactions_update.size).to eq(4)

        expect(recalculation_need_dollar_yen_transactions_update[0].id).to eq(dollar_yen_transaction2_same_day_4.id)
        expect(recalculation_need_dollar_yen_transactions_update[0].date).to eq(dollar_yen_transaction2_same_day_4.date)
        expect(recalculation_need_dollar_yen_transactions_update[1].id).to eq(dollar_yen_transaction3.id)
        expect(recalculation_need_dollar_yen_transactions_update[1].date).to eq(dollar_yen_transaction3.date)
        expect(recalculation_need_dollar_yen_transactions_update[2].id).to eq(dollar_yen_transaction3_2.id)
        expect(recalculation_need_dollar_yen_transactions_update[2].date).to eq(dollar_yen_transaction3_2.date)
        expect(recalculation_need_dollar_yen_transactions_update[3].id).to eq(dollar_yen_transaction4.id)
        expect(recalculation_need_dollar_yen_transactions_update[3].date).to eq(dollar_yen_transaction4.date)
      end

      # 　更新によって再計算が必要なデータを取得する
      # 　条件: 同じ日のトランザジュションデータがある
      #       更新データが最新の日付データ&IDである
      it 'should get recalculation dollar_yen_transactions for update.' do
        dollar_yen_transaction1
        dollar_yen_transaction2_same_day_1
        dollar_yen_transaction2_same_day_2
        # 　これを削除予定
        dollar_yen_transaction2_same_day_3

        recalculation_need_dollar_yen_transactions_update = addresses_eth.recalculation_need_dollar_yen_transactions_update(target_date: dollar_yen_transaction2_same_day_3.date, id: dollar_yen_transaction2_same_day_3.id)
        expect(recalculation_need_dollar_yen_transactions_update.size).to eq(0)
      end
    end
  end

  describe 'base_dollar_yen_transaction_create' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type3) { create(:transaction_type3, address: addresses_eth) }
    let(:transaction_type4) { create(:transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_1) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_2) { create(:dollar_yen_transaction2, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_3) { create(:dollar_yen_transaction2, transaction_type: transaction_type3, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_4) { create(:dollar_yen_transaction2, transaction_type: transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction3_2) { create(:dollar_yen_transaction3, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction4) { create(:dollar_yen_transaction4, transaction_type: transaction_type1, address: addresses_eth) }

    context '作成データ以外の既存データがない' do
      it 'should get empty active record for create.' do
        target_date = Date.new(2020, 1, 1)
        base_dollar_yen_transaction = addresses_eth.base_dollar_yen_transaction_create(target_date: target_date)
        expect(base_dollar_yen_transaction).to be nil
      end
    end

    context '既存データがある' do
      it 'should get base dollar_yen_transaction for create.' do
        dollar_yen_transaction1
        dollar_yen_transaction2_same_day_1
        # ここに既存データを追加
        dollar_yen_transaction3
        dollar_yen_transaction4

        target_date = Date.new(2020, 9, 28)

        base_dollar_yen_transaction = addresses_eth.base_dollar_yen_transaction_create(target_date: target_date)
        expect(base_dollar_yen_transaction).to eq(dollar_yen_transaction2_same_day_1)
      end
    end
  end

  describe 'base_dollar_yen_transaction_delete' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
    let(:transaction_type3) { create(:transaction_type3, address: addresses_eth) }
    let(:transaction_type4) { create(:transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_1) { create(:dollar_yen_transaction2, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_2) { create(:dollar_yen_transaction2, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_3) { create(:dollar_yen_transaction2, transaction_type: transaction_type3, address: addresses_eth) }
    let(:dollar_yen_transaction2_same_day_4) { create(:dollar_yen_transaction2, transaction_type: transaction_type4, address: addresses_eth) }
    let(:dollar_yen_transaction3) { create(:dollar_yen_transaction3, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction3_2) { create(:dollar_yen_transaction3, transaction_type: transaction_type2, address: addresses_eth) }
    let(:dollar_yen_transaction4) { create(:dollar_yen_transaction4, transaction_type: transaction_type1, address: addresses_eth) }

    context '削除データ以外の既存データがない' do
      it 'should get empty active record for delete.' do
        dollar_yen_transaction1

        base_dollar_yen_transaction = addresses_eth.base_dollar_yen_transaction_delete(target_date: dollar_yen_transaction1.date, id: dollar_yen_transaction1.id)
        expect(base_dollar_yen_transaction).to be nil
      end
    end

    context '既存データがある' do
      # 削除によって再計算のベースになるデータを取得する
      # 条件: 同じ日のトランザジュションデータがある
      #      同じ日以外にも変更必要な取引データがある
      it 'should get base dollar_yen_transaction for delete.' do
        dollar_yen_transaction1
        dollar_yen_transaction2_same_day_1
        dollar_yen_transaction2_same_day_2
        # 　これを削除予定
        dollar_yen_transaction2_same_day_3
        dollar_yen_transaction2_same_day_4
        dollar_yen_transaction3
        dollar_yen_transaction3_2
        dollar_yen_transaction4

        base_dollar_yen_transaction = addresses_eth.base_dollar_yen_transaction_delete(target_date: dollar_yen_transaction2_same_day_3.date, id: dollar_yen_transaction2_same_day_3.id)
        expect(base_dollar_yen_transaction).to eq(dollar_yen_transaction2_same_day_2)
      end
    end
  end
end
