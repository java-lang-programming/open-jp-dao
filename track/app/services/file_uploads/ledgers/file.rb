
module FileUploads
  module Ledgers
    class File
      include FileRecord::Header
      # include ActiveRecord::Base
      # include ActiveRecord::Validators::Date
      # include FIleRecord::Csv
      attr_accessor :address, :file, :file_path, :master, :preload, :csv_rows, :import_file

      # これはここ
      DEFAULT_YAML_PATH = "lib/file_record/yamls/ledger.yml"

      def initialize(address:, file:)
        @address = address
        @file = file
        @file_path = file.tempfile.path
        @master = FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::LEDGER_YAML).master
        @preload = { address: @address, ledger_items: LedgerItem.all }
        @csv_rows = make_csv_rows(file_path: @file_path)

        # if import_file.present?
        #             make_csv_rows_via_import(import_file: import_file)
        #           else
        #             make_csv_rows(import_file: file.tempfile.path)
        #           end
      end

      # これは共通化
      # csv_rowsを作成して返す
      def make_csv_rows(file_path:)
        row_num = 0
        # 全てのエラー配列
        csv_rows = []
        CSV.foreach(file_path, headers: false, encoding: "UTF-8") do |row|
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
          all_errors.concat(errors[:errors]) if errors[:errors].present?
        end
        return all_errors unless all_errors.present?
        ImportFileError.error_json_hash(errors: all_errors)
      end

      def validate_errors_first
        all_errors = []
        header_errors = validate_headers
        simple_data_errors = validate_errors_of_simple_data
        all_errors.concat(header_errors[:errors]) if header_errors.present?
        all_errors.concat(simple_data_errors[:errors]) if simple_data_errors.present?
        return ImportFileError.error_json_hash(errors: all_errors) if all_errors.present?
        []
      end

      def create_import_file
        job = Job.find(Job::LEDGER_CSV_IMPORT)
        import_file = @address.import_files.create(job: job, status: :ready)
        import_file.file.attach(@file)
        import_file.save
        import_file
      end
    end
  end
end
