class DollarYenCsvImportJob < ApplicationJob
  queue_as :csv

  def perform(file_path:)
    # TODO リトライ。ログ。エラーハンドリングなども実装する
    service = FileUploads::DollarYenCsv.new(file: file_path)
    service.async_execute
  end
end
