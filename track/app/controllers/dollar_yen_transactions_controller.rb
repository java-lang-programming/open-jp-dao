class DollarYenTransactionsController < ApplicationViewController
  before_action :verify, only: [ :index, :csv_upload, :csv_import ]

  # https://railsguides.jp/action_controller_overview.html
  # https://weseek.co.jp/tech/1211/
  def index
    # default
    limit = params[:limit]
    limit = 50 unless limit.present?
    offset = params[:offset]
    offset = 0 unless offset.present?

    @user = user
    # @notification = { message: "aaaaaaaaaa" }

    base_sql = @session.address.dollar_yen_transactions.preload(:transaction_type)

    @total = base_sql.all.count
    # TODO APIと極力同じにするべき
    @dollaryen_transactions = base_sql.limit(limit).offset(offset).order(date: :desc,  transaction_type_id: :asc)
  end

  def csv_upload
    @user = user
  end

  def csv_import
    @user = user

    file = params[:file]

    unless file.present?
      redirect_to csv_upload_dollar_yen_transactions_path, flash: { errors: [ "uploadファイルが存在しません。ファイルを選択ボタンからファイルを選択してください" ] }
      return
    end

    session = find_session_by_cookie
    address = session.address

    service = FileUploads::DollarYenTransactionDepositCsv.new(address: address, file: file)
    errors = service.validation_errors
    if errors.present?
      redirect_to csv_upload_dollar_yen_transactions_path, flash: { errors: errors }
      # render json: { errors: errors }, status: :bad_request
      return
    end

    job = Job.find(Job::DOLLAR_YENS_TRANSACTIONS_CSV_IMPORT)
    # address = Address.where(address: session.address.address).first

    # https://railsguides.jp/active_storage_overview.html
    # 保存 ステータスも。
    import_file = ImportFile.new(address: address, job: job, status: ImportFile.statuses[:ready])
    import_file.file.attach(file)
    import_file.save

    begin
      DollarYenTransactionsCsvImportJob.perform_later(import_file_id: import_file.id)
    rescue => e
      logger.error "DollarYensTransactionsCsvImportJobに失敗しました: #{e}"
      nil
      # TODO
      # ログを解析して拾えること
      # https://zenn.dev/greendrop/articles/2024-11-07-de79415b55bff0
    end
  end
end
