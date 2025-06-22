
module Files
  class LedgerImportCsv
    include FileRecord::Validator

    attr_accessor :master, :row_num, :row

    # addressとtransactionはcacheを引数で渡すべき
    def initialize(master:, row_num:, row:)
      @master = master
      @row_num = row_num
      @row = row
    end

    # エラーを取得する
    # baseに記載するべき
    # valueの自動化がきついかも。。。
    # ここはValidatoeの共通処理 superで呼び出せるようにする
    def valid_errors
      errors = []
      col = 0
      @master["fields"].each do |field|
        col = col + 1
        content = @master[field]
        if content.present? && content["type"] == "date"
          temp_errors = validate_date(content: content, col: col, row_num: @row_num, feild: field, value: @row[col - 1])
          errors.concat(temp_errors) if temp_errors.present?
        end

        if content.present? && content["type"] == "string"
          temp_errors = validate_string(content: content, col: col, row_num: @row_num, feild: field, value: @row[col - 1])
          errors.concat(temp_errors) if temp_errors.present?
        end

        if content.present? && content["type"] == "bigdecimal"

        end
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
