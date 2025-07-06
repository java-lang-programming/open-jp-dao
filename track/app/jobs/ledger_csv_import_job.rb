# 　レビューにかける
class LedgerCsvImportJob < ApplicationJob
  # BaseCsvImportJob
  queue_as :csv

  # 　ますは動くようにして試験を書く。その後、リファクタリング。両方に適用する。ログはloggableを使う。
  # LedgerCsvにエラーがある
  class LedgerCsvErrors < StandardError; end

  def perform(import_file_id:)
    begin
      # 　上のクラスでやって処理を下でやればいいのでは？
      import_file = ImportFile.find(import_file_id)

      # 実行中にする
      import_file.status = :in_progress
      import_file.save

      # ここからオリジナル
      ledger_import_file = FileUploads::Ledgers::ImportFile.new(import_file: import_file)

      # ledger_csv = FileUploads::LedgerCsv.new(address: import_file.address, file: import_file.file)
      errors = ledger_import_file.validate_errors_of_complex_data
      if errors.present?
        ledger_import_file.save_error(error_json: errors)
        raise LedgerCsvErrors
      end

      # 　オブジェクトの生成
      ledgers = ledger_import_file.generate_ledgers

      # bulk insert
      Ledger.import ledgers, validate: false

      # ステータスを成功
      import_file.status = :completed
      import_file.save
    rescue => e
      puts e
      if import_file.present?
        import_file.status = :failure
        import_file.save
      end
      Rails.error.report(e)
    ensure
      if import_file.present?
        # ファイルの保存は不要なので削除
        import_file.file.purge
      end
    end
  end
end
