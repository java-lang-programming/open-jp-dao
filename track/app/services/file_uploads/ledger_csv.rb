
module FileUploads
  class LedgerCsv
    include FileRecord::Header
    # include ActiveRecord::Base
    # include ActiveRecord::Validators::Date
    attr_accessor :address, :file_path, :master, :preload, :csv_rows, :import_file

    # これはここ
    DEFAULT_YAML_PATH = "lib/file_record/yamls/ledger.yml"

    def initialize(address:, file_path:)
      @address = address
      @file_path = file_path
      @master = FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::LEDGER_YAML).master
      @preload = { address: @address, ledger_items: LedgerItem.all }
      @csv_rows = make_csv_rows
      @import_file = nil
    end

    # csv_rowsを作成して返す
    def make_csv_rows
      row_num = 0
      # 全てのエラー配列
      csv_rows = []
      CSV.foreach(@file_path, headers: false, encoding: "UTF-8") do |row|
        row_num += 1
        next if row_num == 1
        csv_rows << Files::LedgerImportCsvRow.new(master: @master, row_num: row_num, row: row, preload: @preload)
      end
      csv_rows
    end

    # headerのエラー処理
    def validate_headers
      validate_header_fields(file_path: @file_path, master: @master)
    end

    # 処理に時間のかからないシンプルなチェック
    def validate_errors_of_simple_data
      all_errors = []
      @csv_rows.each do |csv_row|
        errors = csv_row.valid_errors
        all_errors.concat(errors) if errors.present?
      end
      all_errors
    end

    # DBなどが絡むデータのチェック
    def validate_errors_of_complex_data
      all_errors = []
      @csv_rows.each do |csv_row|
        error = csv_row.validate_error_of_name
        all_errors << error if error.present?
      end
      all_errors
    end

    # 　非同期処理に入る前のチェック
    def validate_errors_first
      header_errors = validate_headers
      simple_data_errors = validate_errors_of_simple_data
      header_errors.concat(simple_data_errors)
    end

    def create_import_file
      job = Job.find(Job::LEDGER_CSV_IMPORT)

      import_file = address.import_files.create(job: job, status: :ready)
      import_file.file.attach(file_path)
      import_file.save

      @import_file = import_file
    end

    def update_status(status:)
      @import_file ||= create_import_file
      @import_file.status = status
      @import_file.save
    end

    def save_error(error_json:)
      @import_file ||= create_import_file
      @import_file.import_file_errors.create(error_json: error_json.to_json)
    end

    def generate_ledgers
      @csv_rows.map(&:to_ledger)
    end

    def purge_file
      @import_file ||= create_import_file
      @import_file.file.purge
    end
  end
end
