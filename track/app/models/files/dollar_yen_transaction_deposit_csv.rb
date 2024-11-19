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

    # ユニークキーを取得
    def unique_key
      "#{@date}-#{@transaction_type}"
    end

    # ユニークキーハッシュを作成
    def unique_key_hash(unique_key_hash:)
      key = unique_key
      unless unique_key_hash.key?(key)
        rownums = []
        rownums << @row_num
        unique_key_hash = { key => { rownums: rownums } }
      else
        value = unique_key_hash[key]
        rownums = value[:rownums]
        rownums << @row_num
        unique_key_hash = { unique_key => { rownums: rownums } }
      end
      unique_key_hash
    end

    def target_date
      dates = @date.split("/")
      Date.new(dates[0].to_i, dates[1].to_i, dates[2].to_i)
    end

    # DollarYenTransactionに変換
    def to_dollar_yen_transaction(previous_dollar_yen_transactions: nil)
      # 　オブジェクトの変換は共通化ができるはずなので、後でリファクタリング
      address = Address.where(id: @address_id).first
      transaction_type = TransactionType.where(name: @transaction_type, address_id: @address_id).first

      dyt = DollarYenTransaction.new(
        transaction_type: transaction_type,
        date: target_date,
        deposit_rate: BigDecimal(@deposit_rate),
        deposit_quantity: BigDecimal(@deposit_quantity),
        address: address
      )

      en = dyt.calculate_deposit_en if dyt.deposit?
      balance_quantity = dyt.calculate_balance_quantity(previous_dollar_yen_transactions: previous_dollar_yen_transactions)
      balance_en = dyt.calculate_balance_en(previous_dollar_yen_transactions: previous_dollar_yen_transactions)
      balance_rate = dyt.calculate_balance_rate(balance_quantity: balance_quantity, balance_en: balance_en)

      dyt.deposit_en = en if dyt.deposit?
      dyt.balance_quantity = balance_quantity
      dyt.balance_en = balance_en
      dyt.balance_rate = balance_rate
      dyt
    end
  end
end
