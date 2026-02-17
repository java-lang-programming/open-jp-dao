module Files
  class RakutenCardImportCsvRow
    include FileRecord::Validator
    include FileRecord::Type

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
        end
      end
      ImportFileError.error_json_hash(errors: errors)
    end

    # 利用店名・商品名カラムのインデックスを取得
    def product_name_col_index
      @master["fields"].index("利用店名・商品名")
    end

    # 支払い金額カラムのインデックスを取得
    def total_amount_col_index
      @master["fields"].index("支払総額")
    end

    # importする対象であればtrue,そうでなければfalse
    def target?
      return true if find_csv_ledger_item_by_product_name.present?
      false
    end

    # 摘要内容でledger_itemを検索
    def find_csv_ledger_item_by_product_name
      col_index = product_name_col_index
      return nil unless col_index.present?
      product_name = @row[col_index]
      return nil unless product_name.present?
      @preload[:csv_ledgers_items].detect do |csv_ledgers_item|
        if csv_ledgers_item.exact_match?
          csv_ledgers_item.content == product_name
        else
          product_name =~ /#{csv_ledgers_item.content}/
        end
      end
    end

    # face_valueを計算
    def calculate_face_value
      total_amount_col = total_amount_col_index
      total_amount = total_amount_col.present? ? @row[total_amount_col] : nil

      if total_amount.present? && total_amount.to_s.strip != ""
        return money_en_to_integer(value: total_amount)
      end
      nil
    end

    # Ledgerオブジェクトを作成
    def to_ledger
      csv_ledger_item = find_csv_ledger_item_by_product_name
      ledger = Ledger.new(
        address: @preload[:address],
        date: data_for_ufj(field: "利用日"),
        name: @row[product_name_col_index],
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
      to_ledger.to_upsert_all_hash
    end

    # これは共通化できるな
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
      nil
    end
  end
end
