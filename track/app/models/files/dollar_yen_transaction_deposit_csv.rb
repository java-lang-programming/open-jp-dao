module Files
  class DollarYenTransactionDepositCsv
    COLUMN_DATE_INDEX = 0
    COLUMN_TRANSACTION_TYPE_INDEX = 1
    COLUMN_DEPOSIT_QUANTITY_INDEX = 2
    COLUMN_DEPOSIT_RATE_INDEX = 3

    # cache transaction_typeが必要
    attr_accessor :address_id, :row_num, :date, :transaction_type, :deposit_quantity, :deposit_rate

    def initialize(address_id:, row_num:, row:)
      @address_id = address_id
      @row_num = row_num
      @date = row[COLUMN_DATE_INDEX]
      @transaction_type = row[COLUMN_TRANSACTION_TYPE_INDEX]
      @deposit_quantity = row[COLUMN_DEPOSIT_QUANTITY_INDEX]
      @deposit_rate = row[COLUMN_DEPOSIT_RATE_INDEX]
    end

    # エラーを取得する
    def valid_errors
      errors = []
      valid_date?(errors: errors)
      valid_transaction_type?(errors: errors)
      valid_deposit_quantity?(errors: errors)
      valid_deposit_rate?(errors: errors)
      errors
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
        # 　データがある場合はcahaeにするべき。毎回DB接続はあかん
        transaction_type = TransactionType.where(name: @transaction_type, address_id: @address_id).first
        unless transaction_type.present?
          errors << "#{@row_num}行目のtransaction_typeが不正です。正しいtransaction_typeを入力してください"
        end
      else
        errors << "#{@row_num}行目のtransaction_typeが入力されていません"
      end
    end

    # @param errors [Array] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージの配列
    #
    # @deposit_quantityが有効な数値か検証する
    #
    # @deposit_quantity が数値または小数点付きの数値で表せる場合、`errors` 配列は変更されずにそのまま返される。
    #
    # * **数値に変換できない場合:** `errors` 配列に、指定された行番号とエラーメッセージが追加される。
    # * **値が入力されていない場合:** `errors` 配列に、指定された行番号と入力されていない旨のエラーメッセージが追加される。
    #
    def valid_deposit_quantity?(errors:)
      if @deposit_quantity.present?
        begin
          BigDecimal(@deposit_quantity)
          errors
        rescue => e
          errors << "#{@row_num}行目のdeposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください"
        end
      else
        errors << "#{@row_num}行目のdeposit_quantityが入力されていません"
      end
    end

    # @param errors [Array] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージの配列
    #
    # @deposit_rateが有効な数値か検証する
    #
    # @deposit_rate が数値または小数点付きの数値で表せる場合、`errors` 配列は変更されずにそのまま返される。
    #
    # * **数値に変換できない場合:** `errors` 配列に、指定された行番号とエラーメッセージが追加される。
    # * **値が入力されていない場合:** `errors` 配列に、指定された行番号と入力されていない旨のエラーメッセージが追加される。
    #
    def valid_deposit_rate?(errors:)
      if @deposit_rate.present?
        begin
          BigDecimal(@deposit_rate)
          errors
        rescue => e
          errors << "#{@row_num}行目のdeposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください"
        end
      else
        errors << "#{@row_num}行目のdeposit_rateが入力されていません"
      end
    end

    # def valid_deposit?(errors:)
    #   unless @deposit_quantity.present?
    #     errors << "#{@row_num}行目のdeposit_quantityが入力されていません"
    #   else
    #     if @transaction_type.present?
    #       transaction_type = TransactionType.where(name: @transaction_type).first
    #       if transaction_type.present?
    #         dyt = DollarYenTransaction.new(transaction_type: transaction_type, deposit_quantity: @deposit_quantity, deposit_rate: @deposit_rate)
    #         dyt.valid?
    #         if dyt.errors.messages[:deposit_quantity].present?
    #           errors << "#{@row_num}行目のdeposit_quantityが不正です"
    #         end
    #         if dyt.errors.messages[:deposit_rate].present?
    #           errors << "#{@row_num}行目のdeposit_rateが不正です"
    #         end
    #       end
    #     end
    #   end
    # end

    # 　トランザクションデータ作成
    def make_dollar_yen_transactions
      target_date = Date.new(2020, 4, 1)
      transaction_type_id = 1
      dyt = DollarYenTransaction.new(date: target_date, transaction_type: transaction_type_id, deposit_quantity: @deposit_quantity, deposit_rate: deposit_rate)
    end
  end
end
