
module CsvImports
  class DollarYensTransactions

    GENERATE_KIND_INSERT = "insert"
    GENERATE_KIND_UPSERT = "upsert"

    def initialize(import_file:)
      @import_file = import_file
    end

    # csvs [Files::]
    def upsert_dollar_yen_transaction_csvs(csvs: csvs)
      # その日以前のデータを取得してきてdollar_yen_transactionsを作成する
      oldest_date = @import_file.get_oldest_date(csvs: csvs)
      # 以前データより新しいやつは更新が必要なので取得(再計算が必要なデータ)
      address = @import_file.address

      recalculation_need_dollar_yen_transactions = recalculation_need_dollar_yen_transactions(address: address, oldest_date: oldest_date)

      preload_records = { address: address, transaction_types: address.transaction_types }

      old_csvs = to_files_dollar_yen_transactions_csv(
        recalculation_need_dollar_yen_transactions: recalculation_need_dollar_yen_transactions, preload_records: preload_records
      )

      # 今回のcsvと更新が必要な登録済みのデータをmerge
      recalculation_csvs = csvs.concat(old_csvs)

      # id順に並べる
      # recalculation_csvs_soretd_id = recalculation_csvs.sort_by { |csv| csv.id }

      # 日付順に並べる
      recalculation_csvs.sort_by { |csv| csv.date }
    end

    def generate_dollar_yens_transactions
      type = CsvImports::DollarYensTransactions::GENERATE_KIND_INSERT
      # csvデータをcsvオブジェクト一覧にする
      csvs = @import_file.make_csvs_dollar_yens_transactions
      # csvの日付で既存のtransactionより前のデータがあるかを判断
      has_past_date = @import_file.include_past_dollar_yen_transaction?(csvs: csvs)
      if has_past_date
        type = CsvImports::DollarYensTransactions::GENERATE_KIND_UPSERT
        csvs = upsert_dollar_yen_transaction_csvs(csvs: csvs)
      end
      dollar_yen_transactions = Files::DollarYenTransactionDepositCsv.make_dollar_yen_transactions(csvs: csvs)
      {type: type, dollar_yens_transactions: dollar_yen_transactions}
    end

    # データより新しいやつは更新が必要なので取得(再計算が必要なデータ)
    def recalculation_need_dollar_yen_transactions(address:, oldest_date:)
      address.dollar_yen_transactions.where("date >= ?", oldest_date)
    end

    # Files::DollarYenTransactionDepositCsvのオブジェクトに変換
    def to_files_dollar_yen_transactions_csv(recalculation_need_dollar_yen_transactions:, preload_records:)
      recalculation_need_dollar_yen_transactions.map do |dollar_yen_transaction|
        row = dollar_yen_transaction.to_csv_import_format
        Files::DollarYenTransactionDepositCsv.new(address: preload_records[:address], row_num: -1, row: row, preload_records: preload_records)
      end
    end
  end
end
