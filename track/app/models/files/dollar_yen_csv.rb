module Files
  # DollarYenCs
  class DollarYenCsv
    COLUMN_DATE_INDEX = 0
    COLUMN_DOLLAR_YEN_NAKENE_INDEXd = 1

    # date  transaction_type  deposit_quantity  deposit_rate  withdrawal_quantity exchange_en
    COLUMN_NAMES = %i[
      date
      dollar_yen_nakane
    ]

    # cache transaction_typeが必要
    attr_accessor :row_num, :date, :dollar_yen_nakane

    # addressとtransactionはcacheを引数で渡すべき
    def initialize(row_num:, row:)
      @row_num = row_num
      @date = row[COLUMN_DATE_INDEX]
      @dollar_yen_nakane = row[COLUMN_DOLLAR_YEN_NAKENE_INDEXd]
    end

    # エラーを取得する
    def valid_errors
      errors = []
      date_errors(errors: errors)
      dollar_yen_nakane_errors(errors: errors)
      errors
    end

    # @param errors [Array] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージの配列
    #
    # @dateが有効な値か検証する
    #
    def date_errors(errors:)
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
      errors
    end

    # @param errors [Array] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージの配列
    #
    # @dollar_yen_nakaneが有効な値か検証する
    #
    def dollar_yen_nakane_errors(errors:)
      if @dollar_yen_nakane.present?
        begin
          BigDecimal(@dollar_yen_nakane)
          errors
        rescue => e
          errors << "#{@row_num}行目のdollar_yen_nakaneの値が不正です。数値、もしくは小数点付きの数値を入力してください"
        end
      else
        errors << "#{@row_num}行目のdollar_yen_nakaneが入力されていません"
      end
      errors
    end

    # ユニークキーを取得
    def unique_key
      "#{@date}"
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
    def to_dollar_yen
      DollarYen.new(
        date: target_date,
        dollar_yen_nakane: BigDecimal(@dollar_yen_nakane)
      )
    end
  end
end
