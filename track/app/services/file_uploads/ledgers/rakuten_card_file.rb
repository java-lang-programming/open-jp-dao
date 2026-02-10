module FileUploads
  module Ledgers
    class RakutenCardFile
      include FileRecord::Header

      attr_accessor :address, :file, :file_path, :master, :preload, :csv_rows, :import_file

      def initialize(address:, file:)
        @address = address
        @file = file
        @file_path = file.tempfile.path
        @master = FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::RAKUTEN_CARD_YAML).master
        @preload = {} # アップロード時の初期チェックではpreloadは不要
        @csv_rows = make_csv_rows(file_path: @file_path)
      end

      # csv_rowsを作成して返す
      def make_csv_rows(file_path:)
        row_num = 0
        csv_rows = []
        CSV.foreach(file_path, headers: false, encoding: "UTF-8") do |row|
          row_num += 1
          next if row_num == 1
          csv_rows << Files::RakutenCardImportCsvRow.new(master: @master, row_num: row_num, row: row, preload: @preload)
        end
        csv_rows
      end

      # headerのエラー処理
      def validate_headers
        # チェックを除外するフィールド
        exclude_idx = [ 7, 8 ]

        csv_header = nil
        CSV.foreach(@file_path, headers: true, encoding: "UTF-8") do |row|
          csv_header = row.headers
          break
        end

        # TODO 表のエラーと一行エラーは表示変えたい
        # マスタ
        fields_size = @master["fields"].size
        csv_data_size = csv_header.size
        if fields_size < csv_data_size
          row = 1
          message = "ヘッダの属性名の数が多いです。ファイルのヘッダー情報を再確認してください。"
          return ImportFileError.error_json_hash(errors: [ ImportFileError.error_json_data(row: row, message: message) ])
        end

        if fields_size > csv_data_size
          row = 1
          message = "ヘッダの属性名の数が不足しています。ファイルのヘッダー情報を再確認してください。"
          return ImportFileError.error_json_hash(errors: [ ImportFileError.error_json_data(row: row, message: message) ])
        end

        # 数は同じでも、中身が違う場合があるのでチェック
        if fields_size == csv_data_size
          result = @master["fields"].each_with_object([]).with_index do |(field, array), idx|
            next if exclude_idx.include?(idx)
            unless field == csv_header[idx]
              row = 1
              col = idx + 1
              attribute = field
              value = csv_header[idx]
              message = "ヘッダの属性名が不正です。正しい属性名は#{attribute}です。"
              array << ImportFileError.error_json_data(row: row, col: col, attribute: attribute, value: value, message: message)
            end
          end
          return ImportFileError.error_json_hash(errors: result) unless result.empty?
        end
        []
      end

      def create_import_file
        job = Job.find(Job::RAKUTEN_CARD_LEDGER_CSV_IMPORT)
        import_file = @address.import_files.create(job: job, status: :ready)
        import_file.file.attach(@file)
        import_file.save
        import_file
      end
    end
  end
end
