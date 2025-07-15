class ImportFileError < ApplicationRecord
  belongs_to :import_file

  # 　エラーを取り出す
  def fetch_errors
    JSON.parse(error_json, symbolize_names: true)[:errors]
  end

  # TODO error_jsonのschemeのチェック処理を行う

  class << self
    def error_json_data(row:, col: nil, attribute: "", value: "", message: "")
      { row: row, col: col, attribute: attribute, value: value, message: message }
    end

    def error_json_hash(errors: [])
      { errors: errors }
    end
  end
end
