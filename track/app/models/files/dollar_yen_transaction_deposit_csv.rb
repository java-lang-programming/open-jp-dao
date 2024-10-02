module Files
  class DollarYenTransactionDepositCsv
    COLUMN_DATE_INDEX = 0
    COLUMN_TRANSACTION_TYPE_INDEX = 1
    COLUMN_DEPOSIT_QUANTITY_INDEX = 2
    COLUMN_DEPOSIT_RATE_INDEX = 3

    attr_accessor :row_num, :date, :transaction_type, :deposit_quantity, :deposit_rate

    def initialize(row_num:, row:)
      @row_num = row_num
      @date = row[COLUMN_DATE_INDEX]
      @transaction_type = row[COLUMN_TRANSACTION_TYPE_INDEX]
      @deposit_quantity = row[COLUMN_DEPOSIT_QUANTITY_INDEX]
      @deposit_rate = row[COLUMN_DEPOSIT_RATE_INDEX]
    end

    def valid?
      errors = []
      valid_date?(errors: errors)
      valid_transaction_type?(errors: errors)
      errors

      # 空白チェック

      # 　日付のチェック

      # 　データの一意チェック

      # transaction_typeをi
    end

    def valid_date?(errors:)
      if @date.present?
        dates = @date.split("/")
        size = dates.length
        if size != 3
          errors << "#{@row_num}行目のdateのフォーマットが不正です。yyyy/mm/dd形式で入力してください"
        elsif size == 3
          begin
            Date.new(dates[0].to_i, dates[1].to_i, dates[2].to_i)
          rescue => e
            errors << "#{@row_num}行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください"
          end
        end
      else
        errors << "#{@row_num}行目のdateが入力されていません"
      end
    end

    def valid_transaction_type?(errors:)
      if @transaction_type.present?
        transaction_type = TransactionType.where(name: @transaction_type).first
        unless transaction_type.present?
          errors << "#{@row_num}行目のtransaction_typeが不正です。正しいtransaction_typeを入力してください"
        end
      else
        errors << "#{@row_num}行目のtransaction_typeが入力されていません"
      end
    end

    # 　トランザクションデータ作成
    def make_dollar_yen_transactions
      target_date = Date.new(2020, 4, 1)
      transaction_type_id = 1
      dyt = DollarYenTransaction.new(date: target_date, transaction_type: transaction_type_id, deposit_quantity: @deposit_quantity, deposit_rate: deposit_rate)
    end
  end
end
