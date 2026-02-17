class RakutenCardLedgerCsvImportJob < ApplicationJob
  queue_as :csv

  def perform(import_file_id:)
    import_file = nil
    begin
      import_file = ImportFile.find(import_file_id)

      # 実行中にする
      import_file.status = :in_progress
      import_file.save

      # CSVインポート処理
      rakuten_card_import_file = FileUploads::Ledgers::RakutenCardImportFile.new(import_file: import_file)

      # オブジェクトの生成
      ledgers = rakuten_card_import_file.generate_ledgers

      # bulk insert
      Ledger.upsert_all ledgers, unique_by: %i[date name ledger_item_id]

      # ステータスを成功
      import_file.status = :completed
      import_file.save
    rescue => e
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
