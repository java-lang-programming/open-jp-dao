require "csv"
require "yaml"

# 　リファクタリングをして@@file_pathや@masterは無くす
module FileRecord
  module Header
    # yamlをloadする(モジュールかする)
    def yaml_load(path: path)
      # pathは環境変数でも管理可能に
      YAML.load_file(path)
    end

    # 正常の場合は空配列を返す
    def validate_header_fields(file_path:, master:)
      csv_data = CSV.read(file_path, headers: true)
      csv_header = csv_data.headers
      return [] if csv_header == master["fields"]

      # マスタ
      fields_size = master["fields"].size
      csv_data_size = csv_header.size
      # row col atribute value messaga
      if fields_size < csv_data_size
        row = 1
        message = "ヘッダの属性名の数が多いです。ファイルのヘッダー情報を再確認してください。"
        return [ error_data(row: row, message: message) ]
      end

      if fields_size > csv_data_size
        row = 1
        message = "ヘッダの属性名の数が不足しています。ファイルのヘッダー情報を再確認してください。"
        return [ error_data(row: row, message: message) ]
      end

      # 数は同じでも、中身が違う場合があるのでチェック
      if fields_size == csv_data_size
        result = master["fields"].each_with_object([]).with_index do |(field, array), idx|
          # マスタの属性とcsvの属性が異なる
          unless field == csv_header[idx]
            row = 1
            col = idx + 1
            attribute = field
            value = csv_header[idx]
            message = "ヘッダの属性名が不正です。正しい属性名は#{attribute}です。"
            array << error_data(row: row, col: col, attribute: attribute, value: value, message: message)
          end
        end
        result unless result.empty?
      end
    end

    private
    # 色々な箇所で使うね Baseかな
    # TODO private
    def error_data(row:, col: nil, attribute: "", value: "", message: "")
      { row: row, col: col, attribute: attribute, value: value, message: message }
    end
  end
end
