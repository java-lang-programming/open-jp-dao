module FileUploads
  module Ledgers
    class CsvBaseImportFile
      attr_accessor :import_file, :kind, :master, :preload, :csv_rows

      def initialize(import_file:, csv_id:)
        @import_file = import_file
        @kind = Csv.find_kind_by_id(id: csv_id)
        @master = FileUploads::GenerateMaster.new(kind: kind).master
        @preload = { address: import_file.address, csv_ledgers_items: CsvLedgerItem.where(csv_id: csv_id).all }
        make_csv_rows_via_import
      end

      def generate_ledgers
        @csv_rows.map(&:to_upsert_all_ledger)
      end

      # 　子クラスで実体化する
      def create_csv_row(master:, row_num:, row:, preload:)
        raise NotImplementedError, "子クラスで実装してください"
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
            # csv_row = Files::UfjImportCsvRow.new(master: @master, row_num: row_num, row: row, preload: @preload)
            csv_row = create_csv_row(master: @master, row_num: row_num, row: row, preload: @preload)
            csv_rows << csv_row if csv_row.target?
          end
          csv_rows
        end
    end
  end
end
