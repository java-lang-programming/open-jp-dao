
module FileUploads
  module Ledgers
    class ImportFile
      include FileRecord::Header
      # include ActiveRecord::Base
      # include ActiveRecord::Validators::Date
      attr_accessor :import_file, :master, :preload, :csv_rows

      # これはここ
      DEFAULT_YAML_PATH = "lib/file_record/yamls/ledger.yml"

      def initialize(import_file:)
        @import_file = import_file
        @master = FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::LEDGER_YAML).master
        @preload = { address: import_file.address, ledger_items: LedgerItem.all }
        make_csv_rows_via_import(import_file: import_file)
      end

      def make_csv_rows_via_import(import_file:)
        import_file.file.blob.open do |tempfile|
          @csv_rows = make_csv_rows(file_path: tempfile.path)
        end
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

      def validate_errors_of_complex_data
        all_errors = []
        @csv_rows.each do |csv_row|
          error = csv_row.validate_error_of_name
          all_errors << error if error.present?
        end
        return ImportFileError.error_json_hash(errors: all_errors) if all_errors.present?
        []
      end

      def save_error(error_json:)
        @import_file.import_file_errors.create(error_json: error_json.to_json)
      end

      def generate_ledgers
        @csv_rows.map(&:to_upsert_all_ledger)
      end
    end
  end
end
