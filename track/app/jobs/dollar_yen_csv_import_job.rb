class DollarYenCsvImportJob < ApplicationJob
  queue_as :csv

  def perform(import_file_id:)
    import_file = ImportFile.find(import_file_id)
    import_file.status = ImportFile.statuses[:in_progress]
    import_file.save

    # TODO リトライ。ログ。エラーハンドリングなども実装する
    # 引数をfile pathにする
    # 　ちょっと設計がおかしい。。。。
    service = FileUploads::DollarYenCsv.new(file: nil)
    service.async_execute_on_active_job(import_file: import_file)

    import_file.status = ImportFile.statuses[:completed]
    import_file.save
  end
end
