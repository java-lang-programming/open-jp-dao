module FileRecord
  module Validator
    # Validatro**Dateに移植
    # @param content [Hash] エラーメッセージを格納する配列
    # @param col [integer] エラーメッセージを格納する配列
    # @param row_num [integer] エラーメッセージを格納する配列
    # @param field [sring] エラーメッセージを格納する配列
    # @param value [any] エラーメッセージを格納する配列
    # @return [Array] エラーメッセージオブジェクトの配列
    #
    # @dateが有効な値か検証する
    #
    def validate_date(content:, col:, row_num:, field:, value:)
      errors = []
      if content["require"] == true
        unless value.present?
          row = row_num
          col = col
          attribute = field
          value = value
          message = "#{field}が未記入です。#{field}は必須入力です。"
          errors << error_data(row: row, col: col, attribute: attribute, value: value, message: message)
        end
      end

      if value.present? && content["options"].present?
        if content["options"]["format"] == "yyyy/mm/dd"
          dates = value.split("/")
          size = dates.length
          if size != 3
            row = row_num
            col = col
            attribute = field
            value = value
            message = "#{field}のフォーマットが不正です。yyyy/mm/dd形式で入力してください。"
            errors << error_data(row: row, col: col, attribute: attribute, value: value, message: message)
          elsif size == 3
            begin
              Date.new(dates[0].to_i, dates[1].to_i, dates[2].to_i)
            rescue => e
              row = row_num
              col = col
              attribute = field
              value = value
              message = "#{field}の値が不正です。yyyy/mm/dd形式で正しい日付を入力してください。"
              errors << error_data(row: row, col: col, attribute: attribute, value: value, message: message)
            end
          end
        end
      end
      errors
    end

    def validate_string(content:, col:, row_num:, field:, value:)
      errors = []
      # 　これは全部同じ
      if content["require"] == true
        unless value.present?
          row = row_num
          col = col
          attribute = field
          value = value
          message = "#{field}が未記入です。#{field}は必須入力です。"
          errors << error_data(row: row, col: col, attribute: attribute, value: value, message: message)
        end
      end

      if value.present? && content["options"].present?
        max = content["options"]["max"]
        if max.present?
          array = []
          array << value.length
          array << max
          if array.max > max
            row = row_num
            col = col
            attribute = field
            value = value
            message = "#{field}の文字が#{max}文字を超えています。#{max}文字以下にしてください。"
            errors << error_data(row: row, col: col, attribute: attribute, value: value, message: message)
          end
        end
      end
      errors
    end

    def validate_bigdecimal(content:, col:, row_num:, field:, value:)
      errors = []
      errors
    end

    def error_data(row:, col: nil, attribute: "", value: "", message: "")
      { row: row, col: col, attribute: attribute, value: value, message: message }
    end
  end
end
