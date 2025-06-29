module Files
  class LedgerImportCsvRow
    include FileRecord::Validator

    attr_accessor :master, :row_num, :row, :preload

    # addressとtransactionはcacheを引数で渡すべき
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

    def ledger_item_col_index
      @master["fields"].index("ledger_item")
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
        error_data(
          row: @row_num,
          col: col_index + 1,
          attribute: "ledger_item",
          value: name,
          messaga: "#{name}はledger_itemに存在しません"
        )
      end
    end

    def to_ledger
      ledger = Ledger.build(
        address: address,
        date: data_for_ledger(field: "date"),
        name: data_for_ledger(field: "name"),
        ledger_item: find_ledger_item_by_name,
        face_value: data_for_ledger(field: "face_value"),
        proportion_rate: data_for_ledger(field: "proportion_rate"),
        proportion_amount: data_for_ledger(field: "proportion_amount")
      )
      # 　これを実装する
      ledger.recorded_amount = ledger.calculate_recorded_amount
      ledger
    end

    # ledgerオブジェクトのためのデータを取得
    def data_for_ledger(field: "")
      field_col_index = @master["fields"].index(field)
      value = @row[field_col_index]
      content = @master[field]
      if content.present? && content["type"] == "date"
        dates = value.split("/")
        return Date.new(dates[0].to_i, dates[1].to_i, dates[2].to_i)
      end

      if content.present? && content["type"] == "string"
        return value
      end

      if content.present? && content["type"] == "bigdecimal" && value.present?
        return BigDecimal(value)
      end

      nil
    end
  end
end
