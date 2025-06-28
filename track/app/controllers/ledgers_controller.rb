class LedgersController < ApplicationViewController
  before_action :verify, only: [ :index, :csv_upload_new, :csv_upload ]

  def index
    headers
    address = @session.address


    # デフォルトはその年だけ
    # DBの保存方法には気をつける。昔のはあまり見られないはずなので。。。
    # 検索表示用
    base_sql = address.ledgers.preload(:ledger_item)
  end

  def csv_upload_new
    headers
  end

  # 基本同じ処理なので、モジュール化した方が良い。
  def csv_upload
    headers
    address = @session.address

    file = params[:file]

    unless file.present?
      # jsのチェックがあれば来ないはず
      redirect_to csv_upload_new_path, flash: { errors: [ "uploadファイルが存在しません。ファイルを選択ボタンからファイルを選択してください" ] }
      nil
    end

    service = FileUploads::LedgerCsv.new(address: address, file_path: file)
    errors = service.validation_errors
    if errors.present?
      # ここでエラー一覧に遷移するべき
      redirect_to csv_upload_dollar_yen_transactions_path, flash: { errors: errors }
      # render json: { errors: errors }, status: :bad_request
      nil
    end

    job = Job.find(Job::LEDGER_CSV_IMPORT)

    # 保存 ステータスも。
    import_file = ImportFile.new(address: address, job: job, status: ImportFile.statuses[:ready])
    import_file.file.attach(file)
    import_file.save

    begin
      LedgerCsvImportJob.perform_later(import_file_id: import_file.id)
      DollarYenTransactionsCsvImportJob.perform_later(import_file_id: import_file.id)
    rescue => e
      logger.error "LedgerCsvImportJobに失敗しました: #{e}"
      nil
      # TODO
      # ログを解析して拾えること
      # https://zenn.dev/greendrop/articles/2024-11-07-de79415b55bff0
    end
  end
end
