
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
      validate_header_fields(file_path: @file_path, master: @master)
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
        all_errors.concat(errors) if errors.present?
      end
      all_errors
    end
  end
end
