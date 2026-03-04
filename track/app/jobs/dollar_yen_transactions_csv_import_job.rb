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

      ci = CsvImports::DollarYensTransactions.new(import_file: import_file)
      dollar_yens_transactions = ci.generate_dollar_yens_transactions

      DollarYenTransaction.upsert_all(
        dollar_yens_transactions[:dollar_yens_transactions],
        unique_by: %i[date transaction_type_id]
      )

      import_file.status = ImportFile.statuses[:completed]
      import_file.save
    rescue => e
      if import_file.present?
        error_json = ImportFileError.error_json_data(
          row: -1,
          col: -1,
          attribute: "例外処理",
          value: "import",
          message: "#{e}"
        )
        import_file.status = ImportFile.statuses[:failure]
        import_file.import_file_errors.create(
          error_json: ImportFileError.error_json_hash(errors: [ error_json ]).to_json
        )
        import_file.save
      end
      Rails.error.report(e)
    ensure
      # ファイルを削除
      import_file.file.purge
    end
  end
end
