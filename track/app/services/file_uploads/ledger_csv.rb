
module FileUploads
  class LedgerCsv
    include FileRecord::Header
    # include ActiveRecord::Base
    # include ActiveRecord::Validators::Date
    attr_accessor :file, :master

    # これはここ
    DEFAULT_YAML_PATH = "lib/file_record/yamls/ledger.yml"

    def initialize(address:, file_path:)
      @address = address
      @file_path = file_path
      @master = yaml_load(path: "#{Rails.root}/#{DEFAULT_YAML_PATH}")
      @csvs = []
    end

    # headerのエラー処理
    def validate_headers
      validate_header_fileds(file_path: @file_path, master: @master)
    end

    # 共通化
    def valid_data
      row_num = 0
      # 全てのエラー配列
      all_errors = []
      CSV.foreach(@file_path, headers: false, encoding: "UTF-8") do |row|
        row_num += 1
        next if row_num == 1
        # ここから
        csv = Files::LedgerImportCsv.new(master: @master, row_num: row_num, row: row)
        # csv.make_unique_key
        errors = csv.valid_errors


        # TODO arayは入れ子にしない
        all_errors.concat(errors) if errors.present?



        # fields.each do |field|
        #   content = @master[field]
        #   # puts content
        #   if content.present? && content["type"] == "date"
        #     validate_date(content: content, row: line_count, feild: field, value: row[0])
        #   end
        # end
      end
      all_errors
    end

    # include ActiveRecord::Validators::Date
    # def validate_date(content:, row:, feild:, value:)
    #   if content["require"] == true
    #     unless value.present?
    #       row = row
    #       col = 1 # dateは固定だな。。
    #       attribute = feild
    #       value = ""
    #       messaga = "#{feild}が未記入です。#{feild}は必須入力です。"
    #     end
    #   end
    # end
  end
end
