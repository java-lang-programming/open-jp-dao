class DollarYenTransactionsController < ApplicationViewController
  before_action :verify, only: [ :index, :new, :create_confirmation, :csv_upload, :csv_import ]

  # https://railsguides.jp/action_controller_overview.html
  # https://weseek.co.jp/tech/1211/
  def index
    # default
    limit = params[:limit]
    limit = 50 unless limit.present?
    offset = params[:offset]
    offset = 0 unless offset.present?

    header_session
    # @notification = { message: "aaaaaaaaaa" }

    base_sql = @session.address.dollar_yen_transactions.preload(:transaction_type)

    @total = base_sql.all.count
    # TODO APIと極力同じにするべき
    @dollaryen_transactions = base_sql.limit(limit).offset(offset).order(date: :desc,  transaction_type_id: :asc)
  end

  def new
    header_session
    set_view_var
    @dollar_yen_transaction = DollarYenTransaction.new
  end

  # 作成確認
  # TODOここで
  def create_confirmation
    header_session
    # dollar_yen_transactions_pathの繊維の時はいらない
    set_view_var

    request = params.require(:dollar_yen_transaction).permit(:date, :transaction_type, :deposit_quantity, :deposit_rate)

    @dollar_yen_transaction = DollarYenTransaction.new
    @dollar_yen_transaction.transaction_type =  @session.address.transaction_types.where(id: request[:transaction_type]).first
    @errors = {}
    # 　エラー　空白以外のエラーはない
    unless request[:date].present?
      @errors[:date] = "日付は必須入力です"
      # 　ここは共通化やな
      set_view_var
      render "new"
      return
    end

    # 　外に出す
    temp_date = request[:date].split("-")
    date = Date.new(temp_date[0].to_i, temp_date[1].to_i, temp_date[2].to_i)
    @dollar_yen_transaction.date =  date

    unless request[:deposit_quantity].present?
      @errors[:date] = "deposit_quantityは必須入力です"
      render "new"
      return
    else
      # TODO try catch
      # 　数値にできること
      bg_deposit_quantity = BigDecimal(request[:deposit_quantity])
      @dollar_yen_transaction.deposit_quantity = bg_deposit_quantity
    end

    unless request[:deposit_rate].present?
      @errors[:deposit_rate] = "deposit_rateは必須入力です"
      render "new"
      return
    else
      # TODO try catch
      # 　数値にできること
      bg_deposit_rate = BigDecimal(request[:deposit_rate])
      @dollar_yen_transaction.deposit_rate = bg_deposit_rate
    end

    preload_records = @session.preload_records
    recalculation_need_count = @session.address.recalculation_need_dollar_yen_transactions(target_date: @dollar_yen_transaction.date).count
    # 影響ないデータはそのまま更新して一覧画面
    if recalculation_need_count == 0
      csv = @dollar_yen_transaction.to_files_dollar_yen_transaction_csv(row_num: -1, preload_records: preload_records)
      dollar_yen_transaction = csv.to_dollar_yen_transaction(previous_dollar_yen_transactions: nil)
      if dollar_yen_transaction.save
        # 　リダイレクト時にデータを取得?
        redirect_to dollar_yen_transactions_path, flash: { info: "取引データを追加しました" }
        return
      else
        render "new"
      end
      return
    end

    if recalculation_need_count > 50
      @message = "#{params[:dollar_yen_transaction][:date]}以降の取引データが#{recalculation_need_count}件あります。これらの取引を含めて再計算が実行されます。データが多いのでこの処理は非同期で実行します。実行してもよろしいですか。"
    else
      @message = "#{params[:dollar_yen_transaction][:date]}以降の取引データが#{recalculation_need_count}件あります。これらの取引を含めて再計算が実行されます。実行してもよろしいですか。"
    end
  end

  # 作成
  def create
    header_session

    request = params.require(:dollar_yen_transaction).permit(:date, :transaction_type, :deposit_quantity, :deposit_rate)

    # これは共通処理だ
    temp_date = request[:date].split("-")
    date = Date.new(temp_date[0].to_i, temp_date[1].to_i, temp_date[2].to_i)
    dollar_yen_transaction.date = date

    dollar_yen_transaction.transaction_type =  @session.address.transaction_types.where(id: request[:transaction_type]).first

    bg_deposit_quantity = BigDecimal(request[:deposit_quantity])
    dollar_yen_transaction.deposit_quantity = bg_deposit_quantity

    bg_deposit_rate = BigDecimal(request[:deposit_rate])
    dollar_yen_transaction.deposit_rate = bg_deposit_rate

    if recalculation_need_count > 50
      puts "非同期"
      DollarYenTransactionsUpdateJob.perform_later(dollar_yen_transaction: dollar_yen_transaction)
    else
      puts "同期"
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction)
      redirect_to dollar_yen_transactions_path, flash: { info: "取引データを追加しました" }
    end
  end

  def edit
    header_session
  end





  def csv_upload
    header_session
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

  private

    def header_session
      @user = user
    end

    def set_view_var
      @transaction_types = @session.address.transaction_types
    end
end
