module FileUploads
  module Ledgers
    class UfjImportFile
      include FileRecord::Header

      attr_accessor :import_file, :master, :preload, :csv_rows

      DEFAULT_YAML_PATH = "lib/file_record/yamls/ufj.yml"

      def initialize(import_file:)
        @import_file = import_file
        @master = FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::UFJ_YAML).master
        # ここにデータがない？
        @preload = { address: import_file.address, csv_ledgers_items: CsvLedgerItem.where(csv_id: Csv::ID_UFJ).all }
        make_csv_rows_via_import
      end

      # def save_error(error_json:)
      #   @import_file.import_file_errors.create(error_json: error_json.to_json)
      # end

      def generate_ledgers
        @csv_rows.map(&:to_upsert_all_ledger)
      end

      private
        def make_csv_rows_via_import
          @import_file.file.blob.open do |tempfile|
            @csv_rows = make_csv_rows(file_path: tempfile.path)
          end
        end

        def make_csv_rows(file_path:)
          row_num = 0
          csv_rows = []
          CSV.foreach(file_path, headers: false, encoding: "UTF-8") do |row|
            row_num += 1
            next if row_num == 1
            # ここで対象のデータかをチェックしてcsv_rowsに入れる
            csv_row = Files::UfjImportCsvRow.new(master: @master, row_num: row_num, row: row, preload: @preload)
            csv_rows << csv_row if csv_row.target?
          end
          csv_rows
        end
    end
  end
end
