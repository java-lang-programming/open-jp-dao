module Files
  # TODO 名称を変更
  # DollarYenTransactionCsv
  class DollarYenTransactionDepositCsv
    COLUMN_DATE_INDEX = 0
    COLUMN_TRANSACTION_TYPE_NAME_INDEX = 1
    COLUMN_DEPOSIT_QUANTITY_INDEX = 2
    COLUMN_DEPOSIT_RATE_INDEX = 3
    COLUMN_WITHDRAWAL_QUANTITY_INDEX = 4
    COLUMN_EXCHANGE_EN_INDEX = 5

    # date  transaction_type  deposit_quantity  deposit_rate  withdrawal_quantity exchange_en
    COLUMN_NAMES = %i[
      date
      transaction_type
      deposit_quantity
      deposit_rate
      withdrawal_quantity
      exchange_en
    ]

    # cache transaction_typeが必要
    attr_accessor :address, :row_num, :date, :transaction_type_name, :deposit_quantity, :deposit_rate, :withdrawal_quantity, :exchange_en, :transaction_type, :preload_records

    # FIX preload_reofrdにaddressいる？
    # addressとtransactionはcacheを引数で渡すべき
    def initialize(address:, row_num:, row:, preload_records: {})
      @address = address
      @row_num = row_num
      @date = row[COLUMN_DATE_INDEX]
      @transaction_type_name = row[COLUMN_TRANSACTION_TYPE_NAME_INDEX]
      @deposit_quantity = row[COLUMN_DEPOSIT_QUANTITY_INDEX]
      @deposit_rate = row[COLUMN_DEPOSIT_RATE_INDEX]
      @withdrawal_quantity = row[COLUMN_WITHDRAWAL_QUANTITY_INDEX]
      @exchange_en = row[COLUMN_EXCHANGE_EN_INDEX]
      @transaction_type = nil
      @preload_records = preload_records
    end

    # エラーを取得する
    def valid_errors
      errors = []
      valid_date?(errors: errors)
      transaction_type_name_errors(errors: errors)
      deposit_quantity_errors(errors: errors)
      deposit_rate_errors(errors: errors)
      withdrawal_quantity_errors(errors: errors)
      exchange_en_errors(errors: errors)
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

    # @param errors [Array] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージの配列
    #
    # @transaction_type_nameが有効な値か検証する
    #
    def transaction_type_name_errors(errors:)
      if @transaction_type_name.present?
        find_transaction_type
        unless @transaction_type.present?
          errors << "#{@row_num}行目のtransaction_type_nameが不正です。正しいtransaction_type_nameを入力してください"
        end
      else
        errors << "#{@row_num}行目のtransaction_type_nameが入力されていません"
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
    def deposit_quantity_errors(errors:)
      deposit_value_errors(errors: errors, target_name: "deposit_quantity", target_value: @deposit_quantity)
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
    def deposit_rate_errors(errors:)
      deposit_value_errors(errors: errors, target_name: "deposit_rate", target_value: @deposit_rate)
    end

    # @param errors [Array] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージの配列
    #
    # @withdrawal_quantityが有効な数値か検証する
    #
    def withdrawal_quantity_errors(errors:)
      withdrawal_value_errors(errors: errors, target_name: "withdrawal_quantity", target_value: @withdrawal_quantity)
    end

    # @param errors [Array] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージの配列
    #
    # @exchange_enが有効な数値か検証する
    #
    def exchange_en_errors(errors:)
      withdrawal_value_errors(errors: errors, target_name: "exchange_en", target_value: @exchange_en)
    end

    # @param errors [Array] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージの配列
    #
    # deposit時の@target_nameのtarget_valueが有効な数値か検証する
    #
    def deposit_value_errors(errors:, target_name:, target_value:)
      if @transaction_type.present?
        if @transaction_type.deposit?
          if target_value.present?
            begin
              BigDecimal(target_value)
              errors
            rescue => e
              errors << "#{@row_num}行目の#{target_name}の値が不正です。数値、もしくは小数点付きの数値を入力してください"
            end
          else
            errors << "#{@row_num}行目の#{target_name}が入力されていません"
          end
        elsif @transaction_type.withdrawal?
          if target_value.present?
             errors << "#{@row_num}行目の#{target_name}は入力できません。値を削除してください"
          end
        end
      end
      errors
    end

    # @param errors [Array] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージの配列
    #
    # withdrawal時の@target_nameのtarget_valueが有効な数値か検証する
    #
    def withdrawal_value_errors(errors:, target_name:, target_value:)
      if @transaction_type.present?
        if @transaction_type.deposit?
          if target_value.present?
            errors << "#{@row_num}行目の#{target_name}は入力できません。値を削除してください"
          end
        elsif @transaction_type.withdrawal?
          if target_value.present?
            begin
              BigDecimal(target_value)
              errors
            rescue => e
              errors << "#{@row_num}行目の#{target_name}の値が不正です。数値、もしくは小数点付きの数値を入力してください"
            end
          else
            errors << "#{@row_num}行目の#{target_name}が入力されていません"
          end
        end
      end
      errors
    end

    # ユニークキーを取得
    def unique_key
      "#{@date}-#{@transaction_type_name}"
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

    # Files::DollarYenTransactionDepositCsvをDollarYenTransactionに変換する
    #
    # @param previous_dollar_yen_transactions [Files::DollarYenTransactionDepositCsv or nil] csvのファイルオブジェクト
    # @return [DollarYenTransaction] DollarYenTransaction
    def to_dollar_yen_transaction(previous_dollar_yen_transactions: nil)
      @transaction_type ||= find_transaction_type

      # ここの速度が気になる
      dyt = create_dollar_yen_transaction

      # 変数格納
      dyt.deposit_rate = BigDecimal(@deposit_rate.to_s) if dyt.deposit?
      # puts "ここにはきてる"
      dyt.deposit_quantity = BigDecimal(@deposit_quantity.to_s) if dyt.deposit?
      dyt.withdrawal_quantity = BigDecimal(@withdrawal_quantity.to_s) if dyt.withdrawal?
      dyt.exchange_en = BigDecimal(@exchange_en.to_s) if dyt.withdrawal?

      en = dyt.calculate_deposit_en if dyt.deposit?
      withdrawal_rate = dyt.calculate_withdrawal_rate(previous_dollar_yen_transactions: previous_dollar_yen_transactions) if dyt.withdrawal?
      withdrawal_en = dyt.calculate_withdrawal_en(previous_dollar_yen_transactions: previous_dollar_yen_transactions) if dyt.withdrawal?
      balance_quantity = dyt.calculate_balance_quantity(previous_dollar_yen_transactions: previous_dollar_yen_transactions)
      balance_en = dyt.calculate_balance_en(previous_dollar_yen_transactions: previous_dollar_yen_transactions)
      balance_rate = dyt.calculate_balance_rate(balance_quantity: balance_quantity, balance_en: balance_en)
      exchange_difference = dyt.calculate_exchange_difference(withdrawal_en: withdrawal_en) if dyt.withdrawal?

      # 値を設定
      dyt.deposit_en = en
      dyt.withdrawal_rate = withdrawal_rate
      dyt.withdrawal_en = withdrawal_en
      dyt.balance_quantity = balance_quantity
      dyt.balance_en = balance_en
      dyt.balance_rate = balance_rate
      dyt.exchange_difference = exchange_difference
      dyt
    end

    # transaction_typeを取得してインスタンス変数に格納する
    def find_transaction_type
      unless @transaction.present?
        if @preload_records[:transaction_types].present?
          transaction_type = @preload_records[:transaction_types].find { |t| t.name == @transaction_type_name }
          @transaction_type = transaction_type if transaction_type.present?
        else
          @transaction_type ||= TransactionType.where(name: @transaction_type_name, address_id: @address.id).first
        end
      end
    end

    # DollarYenTransactionを作成する
    def create_dollar_yen_transaction
      @transaction_type ||= find_transaction_type
      date = target_date

      new_dyt = DollarYenTransaction.new(
        transaction_type: @transaction_type,
        date: date,
        address: address
      )

      dyt = address.dollar_yen_transactions.where(date: date).where(transaction_type: @transaction_type).first
      new_dyt.id = dyt.id if dyt.present?
      new_dyt
    end

    # Array[Files::DollarYenTransactionDepositCsv]をArray[DollarYenTransaction]に変換する
    #
    # @param csvs [Array[Files::DollarYenTransactionDepositCsv]] csvのファイルオブジェクト一覧
    # @return [Array[DollarYenTransaction]] DollarYenTransactionの一覧
    def self.make_dollar_yen_transactions(csvs:)
      dollar_yen_transactionss = []
      prev_dollar_yen_transaction = nil
      csvs.each_with_index do |item, idx|
        dollar_yen_transaction = item.to_dollar_yen_transaction(previous_dollar_yen_transactions: prev_dollar_yen_transaction)
        dollar_yen_transactionss << dollar_yen_transaction
        prev_dollar_yen_transaction = dollar_yen_transaction
      end
      dollar_yen_transactionss
    end
  end
end
