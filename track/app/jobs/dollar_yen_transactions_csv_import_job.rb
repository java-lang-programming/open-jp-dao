class DollarYenTransactionsCsvImportJob < ApplicationJob
  queue_as :csv

  rescue_from(Exception) do |exception|
    Rails.error.report(exception)
    raise exception
  end

  def perform(import_file_id:)
    begin
      import_file = ImportFile.find(import_file_id)
      import_file.status = ImportFile.statuses[:in_progress]
      import_file.save

      # csvデータをcsvオブジェクト一覧にする
      csvs = import_file.make_csvs_dollar_yens_transactions
      # DB用データに変換
      dollar_yen_transactions = Files::DollarYenTransactionDepositCsv.make_dollar_yen_transactions(csvs: csvs)
      # bulk insert
      DollarYenTransaction.import dollar_yen_transactions, validate: false

      import_file.status = ImportFile.statuses[:completed]
      import_file.save
    rescue => e
      if import_file.present?
        import_file.status = ImportFile.statuses[:failure]
        import_file.save
      end
      Rails.error.report(e)
    ensure
      # ファイルを削除
      import_file.file.purge
    end
  end
end
