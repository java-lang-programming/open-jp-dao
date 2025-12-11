module Files
  class LedgerImportCsvRow
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
      @master[FileUploads::GenerateMaster::LEDGER_YAML_FIELDS].each.with_index do |field, idx|
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

    def ledger_item_col_index
      @master[FileUploads::GenerateMaster::LEDGER_YAML_FIELDS].index("ledger_item")
    end

    def find_ledger_item_by_name
      col_index = ledger_item_col_index
      name = @row[col_index]
      preload[:ledger_items].detect do |ledger_item|
        ledger_item.name == name
      end
    end

    def validate_error_of_name
      ledger_item = find_ledger_item_by_name
      unless ledger_item.present?
        col_index = ledger_item_col_index
        name = @row[col_index]
        ImportFileError.error_json_data(
          row: @row_num,
          col: col_index + 1,
          attribute: "ledger_item",
          value: name,
          message: "#{name}はledger_itemに存在しません"
        )
      end
    end

    def to_ledger
      ledger = Ledger.build(
        address: @preload[:address],
        date: data_for_ledger(field: "date"),
        name: data_for_ledger(field: "name"),
        ledger_item: find_ledger_item_by_name,
        face_value: data_for_ledger(field: "face_value"),
        proportion_rate: data_for_ledger(field: "proportion_rate"),
        proportion_amount: data_for_ledger(field: "proportion_amount")
      )
      ledger.recorded_amount = ledger.calculate_recorded_amount
      ledger
    end

    # ledgerオブジェクトのためのデータを取得
    def data_for_ledger(field: "")
      field_col_index = @master[FileUploads::GenerateMaster::LEDGER_YAML_FIELDS].index(field)
      value = @row[field_col_index]
      content = @master[field]
      if content.present? && content["type"] == "date"
        dates = value.split("/")
        return Date.new(dates[0].to_i, dates[1].to_i, dates[2].to_i)
      end

      if content.present? && content["type"] == "string"
        return value
      end

      if content.present? && content["type"] == TYPE_MONEY_EN
        # 関数にする
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
