module Files
  class UfjImportCsvRow
    include FileRecord::Validator

    # そのうち外だし
    # データがお金の円
    TYPE_MONEY_EN = "money_en"

    attr_accessor :master, :row_num, :row, :preload

    def initialize(master:, row_num:, row:, preload: {})
      @master = master
      @row_num = row_num
      @row = row
      @preload = preload
    end

    # エラーを取得する
    # baseに記載するべき
    # valueの自動化がきついかも。。。
    # ここはValidatoeの共通処理 superで呼び出せるようにする
    def valid_errors
      errors = []
      @master["fields"].each.with_index do |field, idx|
        col = idx + 1
        content = @master[field]
        case content&.dig("type")
        when "date"
          temp_errors = validate_date(content: content, col: col, row_num: @row_num, field: field, value: @row[col - 1])
          errors.concat(temp_errors) if temp_errors.present?
        when "string"
          temp_errors = validate_string(content: content, col: col, row_num: @row_num, field: field, value: @row[col - 1])
          errors.concat(temp_errors) if temp_errors.present?
        when TYPE_MONEY_EN
          temp_errors = validate_money_en(content: content, col: col, row_num: @row_num, field: field, value: @row[col - 1])
          errors.concat(temp_errors) if temp_errors.present?
        when "bigdecimal"
          temp_errors = validate_bigdecimal(content: content, col: col, row_num: @row_num, field: field, value: @row[col - 1])
          errors.concat(temp_errors) if temp_errors.present?
        end
      end
      ImportFileError.error_json_hash(errors: errors)
    end

    # 摘要カラムのインデックスを取得
    def summary_col_index
      @master["fields"].index("摘要")
    end

    # 摘要内容カラムのインデックスを取得
    def summary_content_col_index
      @master["fields"].index("摘要内容")
    end

    # 支払い金額カラムのインデックスを取得
    def payment_amount_col_index
      @master["fields"].index("支払い金額")
    end

    # 預かり金額カラムのインデックスを取得
    def deposit_amount_col_index
      @master["fields"].index("預かり金額")
    end

    # 摘要内容でledger_itemを検索
    def find_csv_ledger_item_by_summary_content
      col_index = summary_content_col_index
      return nil unless col_index.present?
      summary_content = @row[col_index]
      return nil unless summary_content.present?
      puts preload[:csv_ledgers_items].inspect
      # 完全一致じゃない方がいいかも
      preload[:csv_ledgers_items].detect do |csv_ledgers_item|
        csv_ledgers_item.content == summary_content
      end
    end

    # ledger_itemの検証エラーを取得
    def validate_error_of_ledger_item
      ledger_item = find_ledger_item_by_summary_content
      return nil if ledger_item.present?
      col_index = summary_content_col_index
      summary_content = @row[col_index]
      ImportFileError.error_json_data(
        row: @row_num,
        col: col_index + 1,
        attribute: "摘要内容",
        value: summary_content,
        message: "#{summary_content}は仕訳項目と連携されていません"
      )
    end

    # face_valueを計算（支払い金額または預かり金額のどちらか一方が存在する）
    def calculate_face_value
      payment_col = payment_amount_col_index
      deposit_col = deposit_amount_col_index
      payment_value = payment_col.present? ? @row[payment_col] : nil
      deposit_value = deposit_col.present? ? @row[deposit_col] : nil

      if payment_value.present? && payment_value.to_s.strip != ""
        return money_en_to_integer(value: payment_value)
      elsif deposit_value.present? && deposit_value.to_s.strip != ""
        return money_en_to_integer(value: deposit_value)
      end

      nil
    end

    # Ledgerオブジェクトを作成
    def to_ledger
      csv_ledger_item = find_csv_ledger_item_by_summary_content
      ledger = Ledger.new(
        address: @preload[:address],
        date: data_for_ufj(field: "日付"),
        name: @row[summary_content_col_index],
        ledger_item: csv_ledger_item.ledger_item,
        face_value: calculate_face_value,
        proportion_rate: csv_ledger_item.proportion_rate,
        proportion_amount: csv_ledger_item.proportion_amount
      )
      ledger.recorded_amount = ledger.calculate_recorded_amount
      ledger
    end

    # upsert_allを実行するためのhashに変更
    def to_upsert_all_ledger
      ledger = to_ledger
      {
        address_id: ledger.address.id,
        date: ledger.date,
        name: ledger.name,
        ledger_item_id: ledger.ledger_item.id,
        face_value: ledger.face_value,
        proportion_rate: ledger.proportion_rate,
        proportion_amount: ledger.proportion_amount,
        recorded_amount: ledger.recorded_amount
      }
    end

    # ufj.ymlのフィールドからデータを取得
    def data_for_ufj(field: "")
      field_col_index = @master["fields"].index(field)
      return nil unless field_col_index.present?
      value = @row[field_col_index]
      return nil unless value.present?
      content = @master[field]
      if content.present? && content["type"] == "date"
        dates = value.split("/")
        return Date.new(dates[0].to_i, dates[1].to_i, dates[2].to_i)
      end

      if content.present? && content["type"] == "string"
        return value
      end

      if content.present? && content["type"] == TYPE_MONEY_EN
        return money_en_to_integer(value: value)
      end

      if content.present? && content["type"] == "bigdecimal" && value.present?
        return BigDecimal(value)
      end

      nil
    end

    # お金の円をintegerにする
    def money_en_to_integer(value:)
      normalized = value.to_s
                        .delete(",")
                        .gsub(/\A'|'?\Z/, "")

      Integer(normalized)
    end
  end
end
