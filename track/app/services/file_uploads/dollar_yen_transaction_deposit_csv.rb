
module FileUploads
  class DollarYenTransactionDepositCsv
    attr_accessor :file

    def initialize(address:, file:)
      @address = address
      @file = file
      @csvs = []
    end

    def validation_errors
      csv_errors = []
      unique_key_hash = {}
      preload_records =  { address: @address, transaction_types: TransactionType.where(address_id: @address.id) }
      File.open(@file, "r") do |file|
        row_num = 0
        CSV.foreach(file) do |row|
          row_num = row_num + 1
          next if row_num == 1
          csv = Files::DollarYenTransactionDepositCsv.new(address: @address, row_num: row_num, row: row, preload_records: preload_records)
          # csv.make_unique_key
          errors = csv.valid_errors
          if errors.present?
            csv_errors << errors
          end

          # ユニークデータチェックのためのハッシュ
          unique_key_hash = csv.unique_key_hash(unique_key_hash: unique_key_hash)

          @csvs << csv
        end
      end
      # csvのデータにエラーがある
      return csv_errors.flat_map { |a| { msg: a } } if csv_errors.present?
      unique_keys_errors = unique_keys_errors(unique_key_hash: unique_key_hash)
      # ユニークでないキーがある
      return unique_keys_errors.map { |a| { msg: a } } if unique_keys_errors.present?
      []
    end

    # ユニークキー以外を取得
    def unique_keys_errors(unique_key_hash:)
      errors = []
      unique_key_hash.map do |key, values|
        # 重複エラーあり
        if values[:rownums].size > 1
          values[:rownums].each do |value|
            data = key.split("-")
            errors << "#{value}行目の#{data[0]}と#{data[1]}は重複しています"
          end
        end
      end
      errors
    end

    def make_dollar_yen_transactions
      list = []
      prev_dollar_yen_transaction = nil
      @csvs.each_with_index do |item, idx|
        dollar_yen_transaction = item.to_dollar_yen_transaction(previous_dollar_yen_transactions: prev_dollar_yen_transaction)
        prev_dollar_yen_transaction = dollar_yen_transaction
        list << dollar_yen_transaction
      end
      list
    end

    # TODO 並び替え
    # update対応
    def execute
      unless @csvs.present?
        errors = validation_errors
        # 失敗
        return false if errors.present?
      end

      dollar_yen_transactions = make_dollar_yen_transactions

      DollarYenTransaction.import dollar_yen_transactions, validate: false
    end
  end
end
