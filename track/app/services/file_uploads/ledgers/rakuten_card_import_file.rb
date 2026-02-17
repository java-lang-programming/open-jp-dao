module FileUploads
  module Ledgers
    class RakutenCardImportFile < FileUploads::Ledgers::CsvBaseImportFile
      attr_accessor :import_file, :master, :preload, :csv_rows

      def initialize(import_file:)
        super(import_file: import_file, csv_id: Csv::ID_RAKUTEN_CARD)
      end

      # 継承したメソッド
      def create_csv_row(master:, row_num:, row:, preload:)
        Files::RakutenCardImportCsvRow.new(master: master, row_num: row_num, row: row, preload: preload)
      end
    end
  end
end
