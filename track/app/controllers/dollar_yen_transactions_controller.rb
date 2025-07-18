class DollarYenTransactionsController < ApplicationViewController
  before_action :verify, only: [ :index, :new, :create_confirmation, :create, :edit, :edit_confirmation, :update, :delete_confirmation, :destroy, :foreign_exchange_gain, :csv_upload, :csv_import ]

  skip_before_action :verify_authenticity_token, only: [ :update, :destroy ]

  DEFAULT_LIMIT = 50
  # DEFAULT_OFFSET = 0

  def index
    request = params.permit(:transaction_type_id, :page)

    header_session
    address = @session.address
    # 検索表示用
    @transaction_types = address.transaction_types
    # ダウンロード表示用(TODO テスト)
    @downloads = [ { id: "csv_import", name: "csv importファイル" }, { id: "csv_export", name: "csv exportファイル" } ]


    # 検索パラメーター(TODO テスト)
    @transaction_type_id = nil
    if request[:transaction_type_id].present?
      @transaction_type_id = request[:transaction_type_id].to_i
    end

    base_sql = address.dollar_yen_transactions.preload(:transaction_type)
    base_sql = base_sql.where(transaction_type_id: request[:transaction_type_id]) if request[:transaction_type_id].present?
    total = base_sql.all.count

    # ページング処理
    pagy = SimplePagy::Pagy.new(request_page: request[:page], request_query: request).build(total: total)

    dollaryen_transactions = base_sql.limit(DEFAULT_LIMIT).offset(pagy.offset).order(date: :desc,  transaction_type_id: :asc)
    # result = base_sql.order(date: :desc,  transaction_type_id: :asc)
    @dollaryen_transactions = dollaryen_transactions.map do |dollaryen_transaction|
      {
        id: dollaryen_transaction.id,
        date: dollaryen_transaction.date.strftime("%Y/%m/%d"),
        transaction_type_name: dollaryen_transaction.transaction_type.name,
        deposit_rate: Unit.add_unit(value: dollaryen_transaction.deposit_rate_on_screen, unit: Unit::EN_DOLLAR),
        deposit_quantity: Unit.add_unit(value: dollaryen_transaction.deposit_quantity_on_screen, unit: Unit::EN_DOLLAR),
        deposit_en: dollaryen_transaction.deposit_en_screen,
        withdrawal_rate: Unit.add_unit(value: dollaryen_transaction.withdrawal_rate_on_screen, unit: Unit::EN_DOLLAR),
        withdrawal_quantity: Unit.add_unit(value: dollaryen_transaction.withdrawal_quantity_on_screen, unit: Unit::EN_DOLLAR),
        withdrawal_en: dollaryen_transaction.withdrawal_en_on_screen,
        balance_rate: Unit.add_unit(value: dollaryen_transaction.balance_rate_on_screen, unit: Unit::EN_DOLLAR),
        balance_quantity: Unit.add_unit(value: dollaryen_transaction.balance_quantity_on_screen, unit: Unit::EN_DOLLAR),
        balance_en: dollaryen_transaction.balance_en_on_screen
      }
    end
    # 下記がうまく言ったらpagyをそのまま置き換えるようにする
    @page = { total: pagy.total, page: pagy.page, current_page: pagy.current_page, start_data_number: pagy.start_data_number, end_data_number: pagy.end_data_number, prev_query: pagy.prev_query, next_query: pagy.next_query, pages: pagy.pages_query }
  end

  def new
    header_session
    set_view_var
    @dollar_yen_transaction = DollarYenTransaction.new

    @deposit_section_block = "block;"
    @withdrawal_section_block = "none;"

    # クラスの指定(分ける)
    @errors = {}
    @errors[:date_class] = "form_input"
    @errors[:date_msg] = ""
    @errors[:deposit_quantity_class] = "form_input"
    @errors[:deposit_quantity_msg] = ""
    @errors[:deposit_rate_class] = "form_input"
    @errors[:deposit_rate_msg] = ""
    @errors[:withdrawal_quantity_class] = "form_input"
    @errors[:withdrawal_quantity_msg] = ""
    @errors[:exchange_en_class] = "form_input"
    @errors[:exchange_en_msg] = ""
  end

  # 作成確認
  # TODOここで
  def create_confirmation
    header_session
    # dollar_yen_transactions_pathの繊維の時はいらない
    set_view_var

    request = params.require(:dollar_yen_transaction).permit(:date, :transaction_type_id, :deposit_quantity, :deposit_rate, :withdrawal_quantity, :exchange_en)
    transaction_type = @session.address.transaction_types.where(id: request[:transaction_type_id]).first

    req = Requests::DollarYensTransaction.new(date: request[:date], transaction_type: transaction_type, deposit_quantity: request[:deposit_quantity], deposit_rate: request[:deposit_rate], withdrawal_quantity: request[:withdrawal_quantity], exchange_en: request[:exchange_en])
    errors = req.get_errors

    if errors.present?
      set_view_var
      @dollar_yen_transaction = req.to_dollar_yen_transaction(errors: errors, address: @session.address)
      @deposit_section_block = req.deposit_block
      @withdrawal_section_block = req.withdrawal_block

      @errors = {}
      @errors[:date_class] = "form_input form_input_ng"
      if errors[:date].present?
        @errors[:date_msg] = errors[:date]
      else
        @errors[:date_class] = "form_input form_input_ok"
      end
      @errors[:deposit_quantity_class] = "form_input form_input_ng"
      if errors[:deposit_quantity].present?
        @errors[:deposit_quantity_msg] = errors[:deposit_quantity]
      else
        @errors[:deposit_quantity_class] = "form_input form_input_ok"
      end
      @errors[:deposit_rate_class] = "form_input form_input_ng"
      if errors[:deposit_rate].present?
        @errors[:deposit_rate_msg] = errors[:deposit_rate]
      else
        @errors[:deposit_rate_class] = "form_input form_input_ok"
      end
      @errors[:withdrawal_quantity_class] = "form_input form_input_ng"
      if errors[:withdrawal_quantity].present?
        @errors[:withdrawal_quantity_msg] = errors[:withdrawal_quantity]
      else
        @errors[:withdrawal_quantity_class] = "form_input form_input_ok"
      end
      @errors[:exchange_en_class] = "form_input form_input_ng"
      if errors[:exchange_en].present?
        @errors[:exchange_en_msg] = errors[:exchange_en]
      else
        @errors[:exchange_en_class] = "form_input form_input_ok"
      end
      render "new"
      return
    end

    @dollar_yen_transaction = req.to_dollar_yen_transaction(errors: errors, address: @session.address)

    recalculation_need_count = @session.address.recalculation_need_dollar_yen_transactions_create(target_date: @dollar_yen_transaction.date).count
    # 影響ないデータはそのまま更新して一覧画面
    if recalculation_need_count == 0
      csv = @dollar_yen_transaction.to_files_dollar_yen_transaction_csv(row_num: -1, preload_records: @session.preload_records)
      dollar_yen_transaction = csv.to_dollar_yen_transaction(previous_dollar_yen_transactions: nil)
      if dollar_yen_transaction.save
        # 　リダイレクト時にデータを取得?
        redirect_to dollar_yen_transactions_path, flash: { notice: "取引データを追加しました" }
        return
      end
      render "new"
      return
    end

    if recalculation_need_count > 50
      @message = "#{params[:dollar_yen_transaction][:date]}以降の取引データが#{recalculation_need_count}件あります。これらの取引を含めて再計算が実行されます。データが多いのでこの処理は非同期で実行します。実行してもよろしいですか。"
    else
      @message = "#{params[:dollar_yen_transaction][:date]}以降の取引データが#{recalculation_need_count}件あります。これらの取引を含めて再計算が実行されます。実行してもよろしいですか。"
    end

    render :create_confirmation
  end

  # 作成
  def create
    header_session

    request = params.require(:dollar_yen_transaction).permit(:date, :transaction_type_id, :deposit_quantity, :deposit_rate)
    dollar_yen_transaction = reqest_to_dollar_yen_transaction(request: request)

    recalculation_need_count = @session.address.recalculation_need_dollar_yen_transactions_create(target_date: dollar_yen_transaction.date).count
    if recalculation_need_count > 50
      DollarYenTransactionsUpdateJob.perform_later(dollar_yen_transaction: dollar_yen_transaction, kind: DollarYenTransaction::KIND_CREATE)
    else
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction, kind: DollarYenTransaction::KIND_CREATE)
      redirect_to dollar_yen_transactions_path, flash: { notice: "取引データを更新・追加しました" }
    end
  end

  def edit
    header_session
    address = @session.address
    @dollar_yen_transaction = address.dollar_yen_transactions.where(id: params[:id]).first
    @transaction_types = address.transaction_types.where(kind: @dollar_yen_transaction.transaction_type.kind)


    # クラスの指定(分ける)
    @deposit_section_block = "block;"
    @withdrawal_section_block = "none;"

    @errors = {}
    @errors[:date_class] = "form_input"
    @errors[:date_msg] = ""
    @errors[:deposit_quantity_class] = "form_input"
    @errors[:deposit_quantity_msg] = ""
    @errors[:deposit_rate_class] = "form_input"
    @errors[:deposit_rate_msg] = ""
    @errors[:withdrawal_quantity_class] = "form_input"
    @errors[:withdrawal_quantity_msg] = ""
    @errors[:exchange_en_class] = "form_input"
    @errors[:exchange_en_msg] = ""
  end

  def edit_confirmation
    header_session
    # dollar_yen_transactions_pathの繊維の時はいらない
    address = @session.address

    request = params.require(:dollar_yen_transaction).permit(:date, :transaction_type_id, :deposit_quantity, :deposit_rate, :withdrawal_quantity, :exchange_en)
    transaction_type = address.transaction_types.where(id: request[:transaction_type_id]).first
    @transaction_types = address.transaction_types.where(kind: transaction_type.kind)

    req = Requests::DollarYensTransaction.new(id: params[:id], date: request[:date], transaction_type: transaction_type, deposit_quantity: request[:deposit_quantity], deposit_rate: request[:deposit_rate], withdrawal_quantity: request[:withdrawal_quantity], exchange_en: request[:exchange_en])
    errors = req.get_errors

    if errors.present?
      set_view_var
      @dollar_yen_transaction = req.to_dollar_yen_transaction(errors: errors, address: address)
      @deposit_section_block = req.deposit_block
      @withdrawal_section_block = req.withdrawal_block

      @errors = {}
      @errors[:date_class] = "form_input form_input_ng"
      if errors[:date].present?
        @errors[:date_msg] = errors[:date]
      else
        @errors[:date_class] = "form_input form_input_ok"
      end
      @errors[:deposit_quantity_class] = "form_input form_input_ng"
      if errors[:deposit_quantity].present?
        @errors[:deposit_quantity_msg] = errors[:deposit_quantity]
      else
        @errors[:deposit_quantity_class] = "form_input form_input_ok"
      end
      @errors[:deposit_rate_class] = "form_input form_input_ng"
      if errors[:deposit_rate].present?
        @errors[:deposit_rate_msg] = errors[:deposit_rate]
      else
        @errors[:deposit_rate_class] = "form_input form_input_ok"
      end
      @errors[:withdrawal_quantity_class] = "form_input form_input_ng"
      if errors[:withdrawal_quantity].present?
        @errors[:withdrawal_quantity_msg] = errors[:withdrawal_quantity]
      else
        @errors[:withdrawal_quantity_class] = "form_input form_input_ok"
      end
      @errors[:exchange_en_class] = "form_input form_input_ng"
      if errors[:exchange_en].present?
        @errors[:exchange_en_msg] = errors[:exchange_en]
      else
        @errors[:exchange_en_class] = "form_input form_input_ok"
      end
      return render "edit"
    end

    @dollar_yen_transaction = address.dollar_yen_transactions.where(id: params[:id]).first
    @dollar_yen_transaction.deposit_quantity = BigDecimal(request[:deposit_quantity])
    @dollar_yen_transaction.deposit_rate = BigDecimal(request[:deposit_rate])

    recalculation_need_count = address.recalculation_need_dollar_yen_transactions_update(target_date: @dollar_yen_transaction.date, id: @dollar_yen_transaction.id).count

    # 最新データだけの場合はそのまま更新
    if recalculation_need_count == 0
      csv = @dollar_yen_transaction.to_files_dollar_yen_transaction_csv(row_num: -1, preload_records: @session.preload_records)
      dollar_yen_transaction = csv.to_dollar_yen_transaction(previous_dollar_yen_transactions: address.base_dollar_yen_transaction_update(target_date: @dollar_yen_transaction.date, id: @dollar_yen_transaction.id))
      # 　TODO ここでswap(ますはこれから)
      @dollar_yen_transaction.transaction_type = transaction_type
      @dollar_yen_transaction.deposit_en = dollar_yen_transaction.deposit_en
      @dollar_yen_transaction.withdrawal_rate = dollar_yen_transaction.withdrawal_rate
      @dollar_yen_transaction.withdrawal_quantity = dollar_yen_transaction.withdrawal_quantity
      @dollar_yen_transaction.withdrawal_en = dollar_yen_transaction.withdrawal_en
      @dollar_yen_transaction.balance_rate = dollar_yen_transaction.balance_rate
      @dollar_yen_transaction.balance_quantity = dollar_yen_transaction.balance_quantity
      @dollar_yen_transaction.balance_en = dollar_yen_transaction.balance_en
      @dollar_yen_transaction.exchange_en = dollar_yen_transaction.exchange_en
      @dollar_yen_transaction.exchange_difference = dollar_yen_transaction.exchange_difference

      if @dollar_yen_transaction.save
        # 　リダイレクト時にデータを取得?
        redirect_to dollar_yen_transactions_path, flash: { notice: "取引データを更新しました" }
        return
      end
      return :edit
    end

    if recalculation_need_count > 50
      @message = "#{params[:dollar_yen_transaction][:date]}以降の取引データが#{recalculation_need_count}件あります。これらの取引を含めて再計算が実行されます。データが多いのでこの処理は非同期で実行します。実行してもよろしいですか。"
    else
      @message = "#{params[:dollar_yen_transaction][:date]}以降の取引データが#{recalculation_need_count}件あります。これらの取引を含めて再計算が実行されます。実行してもよろしいですか。"
    end
  end

  def update
    address = @session.address

    request = params.require(:dollar_yen_transaction).permit(:id, :date, :transaction_type_id, :deposit_quantity, :deposit_rate)
    dollar_yen_transaction = address.dollar_yen_transactions.where(id: params[:id]).first
    transaction_type = address.transaction_types.where(id: request[:transaction_type_id]).first

    dollar_yen_transaction.transaction_type = transaction_type
    dollar_yen_transaction.deposit_quantity = BigDecimal(request[:deposit_quantity])
    dollar_yen_transaction.deposit_rate = BigDecimal(request[:deposit_rate])

    recalculation_need_count = address.recalculation_need_dollar_yen_transactions_update(target_date: dollar_yen_transaction.date, id: dollar_yen_transaction.id).count
    if recalculation_need_count > 50
      DollarYenTransactionsUpdateJob.perform_later(dollar_yen_transaction: dollar_yen_transaction, kind: DollarYenTransaction::KIND_UPDATE)
    else
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction, kind: DollarYenTransaction::KIND_UPDATE)
      redirect_to dollar_yen_transactions_path, flash: { notice: "取引データを更新・追加しました" }
    end
  end

  def delete_confirmation
    header_session

    address = @session.address

    @dollar_yen_transaction = address.dollar_yen_transactions.where(id: params[:id]).first

    recalculation_need_count = address.recalculation_need_dollar_yen_transactions_delete(target_date: @dollar_yen_transaction.date, id: @dollar_yen_transaction.id).count
    if recalculation_need_count == 0
      @dollar_yen_transaction.destroy
      redirect_to dollar_yen_transactions_path, flash: { notice: "取引データを削除しました" }
      return
    end

    if recalculation_need_count > 50
      @message = "#{@dollar_yen_transaction.date}以降の取引データが#{recalculation_need_count}件あります。削除をするとこれらの取引にも再計算が実行されます。データが多いのでこの処理は非同期で実行します。実行してもよろしいですか。"
    else
      @message = "#{@dollar_yen_transaction.date}以降の取引データが#{recalculation_need_count}件あります。削除をするとこれらの取引にも再計算が実行されます。実行してもよろしいですか。"
    end
  end

  # https://www.airteams.net/media/articles/1830
  def destroy
    address = @session.address

    # ここはテスト可能にする
    # ターゲット
    dollar_yen_transaction = address.dollar_yen_transactions.where(id: params[:id]).first

    # 基準となる取引
    base_dollar_yen_transaction = address.base_dollar_yen_transaction_delete(target_date: dollar_yen_transaction.date, id: dollar_yen_transaction.id)

    # 再計算が必要な取引
    recalculation_need_count = address.recalculation_need_dollar_yen_transactions_delete(target_date: dollar_yen_transaction.date, id: dollar_yen_transaction.id).count
    if recalculation_need_count > 50
      DollarYenTransactionsUpdateJob.perform_later(dollar_yen_transaction: dollar_yen_transaction, kind: DollarYenTransaction::KIND_DELETE)
    else
      DollarYenTransactionsUpdateJob.perform_now(dollar_yen_transaction: dollar_yen_transaction, kind: DollarYenTransaction::KIND_DELETE)
      redirect_to dollar_yen_transactions_path, flash: { notice: "取引データを削除し、変更があるデータを再計算しました" }
    end
  end

  def foreign_exchange_gain
    header_session

    address = @session.address

    base_sql = address.dollar_yen_transactions
    @dollar_yen_transactions_total = base_sql.all.count

    # データが存在しない場合はドル円外貨預金元帳に遷移する
    redirect_to dollar_yen_transactions_path if @dollar_yen_transactions_total == 0

    # データのある年度を取得 sqlite3のみ(postgres:EXTRACT(year FROM date))
    years = base_sql.order(date: :desc).distinct.pluck(Arel.sql("strftime('%Y', date)"))
    @years = years.map do |year|
      [ year.to_s, name: year ]
    end

    year = params[:year]
    year = Date.today.year unless year.present?
    @year = year.to_s

    # http://localhost:3000/apis/dollaryen/foreigne_exchange_gain?address=0x00001E868c62FA205d38BeBaB7B903322A4CC89D?year=2024
    transaction_type_ids = address.withdrawal_transaction_type_ids

    # ここでwithdrawalを取得
    start_date = Time.new(year, 1, 1)
    end_date = Time.new(year, 12, 31)

    dollaryen_transactions = address.dollar_yen_transactions.preload(:transaction_type).where(transaction_type_id: transaction_type_ids).where(date: (start_date..end_date))
    @total = dollaryen_transactions.count

    # 為替差額
    foreign_exchange_gain = dollaryen_transactions.inject (0) { |sum, t| sum += Fraction.en(value: t.exchange_difference) }
    @foreign_exchange_gain = Fraction.en(value: foreign_exchange_gain)

    @responses = dollaryen_transactions.map do |dollaryen_transaction|
      {
        date: dollaryen_transaction.date.strftime("%Y/%m/%d"),
        transaction_type_name: dollaryen_transaction.transaction_type.name,
        withdrawal_rate:  dollaryen_transaction.withdrawal_rate_on_screen,
        withdrawal_quantity: dollaryen_transaction.withdrawal_quantity_on_screen,
        withdrawal_en: dollaryen_transaction.withdrawal_en_on_screen,
        exchange_en: dollaryen_transaction.exchange_en_on_screen,
        exchange_difference: dollaryen_transaction.exchange_difference_on_screen
      }
    end

    @start_date = start_date.strftime("%Y-%m-%d")
    @end_date = end_date.strftime("%Y-%m-%d")
    # render json: { date: { start_date: start_date.strftime("%Y-%m-%d"), end_date: end_date.strftime("%Y-%m-%d") }, data: { total: total, dollaryen_transactions: responses }, foreign_exchange_gain: foreign_exchange_gain.floor(2).to_f }, status: :ok
  end

  def csv_upload
    header_session
    @import_file = ImportFile.new
  end

  def csv_import
    @user = user

    file = params[:import_file][:file]

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
      @notification = notification
    end

    def set_view_var
      @transaction_types = @session.address.transaction_types
    end

    # エラーがない前提でリクエストをdollar_yen_transactionにする
    def reqest_to_dollar_yen_transaction(request:)
      dollar_yen_transaction = DollarYenTransaction.new
      splited_date = request[:date].split("-")
      date = Date.new(splited_date[0].to_i, splited_date[1].to_i, splited_date[2].to_i)
      dollar_yen_transaction.date = date
      dollar_yen_transaction.address = @session.address
      dollar_yen_transaction.transaction_type = @session.address.transaction_types.where(id: request[:transaction_type]).first
      dollar_yen_transaction.deposit_quantity = BigDecimal(request[:deposit_quantity])
      dollar_yen_transaction.deposit_rate = BigDecimal(request[:deposit_rate])
      dollar_yen_transaction
    end
end
