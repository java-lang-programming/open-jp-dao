class DollarYenTransactionsCsvImportJob < ApplicationJob
  queue_as :csv

  rescue_from(Exception) do |exception|
    Rails.error.report(exception)
    raise exception
  end

  def perform(import_file_id:)
    begin
      import_file = ImportFile.find(import_file_id)
      import_file.status = ImportFile.statuses[:in_progress]
      import_file.save

      # ここから処理の共通化


      # 1. csvの日付で既存のtransactionより雨のデータがあるかを判断

      # csvデータをcsvオブジェクト一覧にする
      csvs = import_file.make_csvs_dollar_yens_transactions
      # puts import_file.id
      # puts csvs.inspect
      # csvの日付で既存のtransactionより雨のデータがあるかを判断
      has_past_date = import_file.include_past_dollar_yen_transaction?(csvs: csvs)
      # puts "has_past_date"
      # puts has_past_date
      if has_past_date
        # 過去データあり
        # その日以前のデータを取得してきてdollar_yen_transactionsを作成する
        oldest_date = import_file.get_oldest_date(csvs: csvs)
        # 以前データより新しいやつは更新が必要なので取得(再計算が必要なデータ)
        need_recalculation_dollar_yen_transactions = import_file.address.dollar_yen_transactions.where("date >= ?", oldest_date)
        # 再計算に使う一つ前のデータ
        previous_dollar_yen_transaction = import_file.address.dollar_yen_transactions.where("date < ?", oldest_date).first

        # puts previous_dollar_yen_transaction.inspect
        # puts previous_dollar_yen_transaction.to_csv_import



        # ここで
        # csvデータにする
        preload_records =  { address: import_file.address, transaction_types: import_file.address.transaction_types }
        old_csvs = need_recalculation_dollar_yen_transactions.map do |dollar_yen_transaction|
          row = dollar_yen_transaction.to_csv_import_format
          Files::DollarYenTransactionDepositCsv.new(address: import_file.address, row_num: -1, row: row, preload_records: preload_records)
        end

        base_csv = Files::DollarYenTransactionDepositCsv.new(address: import_file.address, row_num: -1, row: previous_dollar_yen_transaction.to_csv_import, preload_records: preload_records)
        # puts base_csv.inspect


        # 全部合わせる
        # concat( [previous_dollar_yen_transaction.to_csv_import] )
        recalculation_csvs = [ base_csv ].concat(csvs).concat(old_csvs)
        # recalculation_csvs = recalculation_csvs.concat( old_csvs )
        recalculation_csvs.each do |csv|
          puts csv.date
        end

        puts "---------"

        # 日付順に並べる(同じ日付がある時は。type_idで)
        new_csvs = recalculation_csvs.sort_by { |csv| csv.date }
        # new_csvs.each do |csv|
        #   puts csv.date
        # end

        dollar_yen_transactions = Files::DollarYenTransactionDepositCsv.make_dollar_yen_transactions(csvs: new_csvs)
        # TODO bulk insert upset
        DollarYenTransaction.import dollar_yen_transactions, on_duplicate_key_update: [ :transaction_type_id, :date ],  validate: true
      else
        # 過去データなし
        # DB用データに変換
        dollar_yen_transactions = Files::DollarYenTransactionDepositCsv.make_dollar_yen_transactions(csvs: csvs)
        # TODO bulk insert upset
        DollarYenTransaction.import dollar_yen_transactions, validate: false
      end

      import_file.status = ImportFile.statuses[:completed]
      import_file.save
    rescue => e
      if import_file.present?
        import_file.status = ImportFile.statuses[:failure]
        import_file.save
      end
      Rails.error.report(e)
    ensure
      # ファイルを削除
      import_file.file.purge
    end
  end
end
