class DollarYenCsvImportJob < ApplicationJob
  queue_as :csv

  def perform(import_file_id:)
    import_file = ImportFile.find(import_file_id)
    # puts import_file.file.path
    # https://stackoverflow.com/questions/48749767/rails-read-csv-file-data-with-active-storage

    # puts "download"
    # puts import_file.file.inspect

    # puts "open"
    # # https://patorash.hatenablog.com/entry/2020/11/21/031355
    # import_file.file.open do |file|
    #   row_num = 0
    #   CSV.foreach(file) do |row|
    #     puts row
    #   end
    # end
    # File.open(import_file.file.download, "r") do |file|
    # row_num = 0
    # CSV.foreach(file) do |row|
    # 	puts row
    # end
    # end

    # TODO リトライ。ログ。エラーハンドリングなども実装する
    # 引数をfile pathにする
    # 　ちょっと設計がおかしい。。。。
    service = FileUploads::DollarYenCsv.new(file: nil)
    service.async_execute_on_active_job(import_file: import_file)
  end
end
