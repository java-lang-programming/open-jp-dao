
module Csvs
  class Ufj
    attr_accessor :file_path

    def initialize(file_path:)
      @file = file
      @csvs = []
    end

    # def validation_errors
    #   File.open(@file, "r") do |file|
    #     row_num = 0
    #     CSV.foreach(file) do |row|
    #       #　headerのチェック
    #       row_num = row_num + 1
    #       next if row_num == 1
    #       data = row[0]
    #     end
    #   end
    #   # csvのデータにエラーがある
    #   return csv_errors.flat_map { |a| { msg: a } } if csv_errors.present?
    #   unique_keys_errors = unique_keys_errors(unique_key_hash: unique_key_hash)
    #   # ユニークでないキーがある
    #   return unique_keys_errors.map { |a| { msg: a } } if unique_keys_errors.present?
    #   []
    # end
  end
end
