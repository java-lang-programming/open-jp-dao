class LedgersController < ApplicationViewController
  before_action :verify, only: [ :index, :destroy_multiple, :csv_upload_new, :csv_upload ]

  DEFAULT_LIMIT = 50

  def index
    request = params.permit(:ledger_item_id, :page)

    headers
    address = @session.address

    # 画面表示項目
    assign_screen_items

    # 検索パラメーター(TODO テスト)
    @ledger_item_id = nil
    if request[:ledger_item_id].present?
      @ledger_item_id = request[:ledger_item_id].to_i
    end

    # デフォルトはその年だけ
    # DBの保存方法には気をつける。昔のはあまり見られないはずなので。。。
    # 検索表示用
    base_sql = address.ledgers.preload(:ledger_item)
    base_sql = base_sql.where(ledger_item_id: @ledger_item_id) if @ledger_item_id.present?
    total = base_sql.all.count

    # ページング処理
    pagy = SimplePagy::Pagy.new(request_page: request[:page], request_query: request).build(total: total)

    ledgers = base_sql.limit(DEFAULT_LIMIT).offset(pagy.offset).order(date: :desc)
    @ledgers = ledgers.map do |ledger|
      {
        id: ledger.id,
        date: ledger.date.strftime("%Y/%m/%d"),
        ledger_item_name: ledger.ledger_item.name,
        name: ledger.name,
        face_value: ledger.face_value_screen,
        proportion_amount: ledger.proportion_amount_screen,
        proportion_rate: ledger.proportion_rate_screen,
        recorded_amount: ledger.recorded_amount_screen
      }
    end
    # 下記がうまく言ったらpagyをそのまま置き換えるようにする
    @page = { total: pagy.total, page: pagy.page, current_page: pagy.current_page, start_data_number: pagy.start_data_number, end_data_number: pagy.end_data_number, prev_query: pagy.prev_query, next_query: pagy.next_query, pages: pagy.pages_query }
  end

  def new
    headers
    @ledger = Ledger.new
    view = Views::LedgerForm.new
    @forms = view.form
    assign_screen_items
  end

  def create
    request = params.require(:ledger).permit(:date, :ledger_item_id, :name, :face_value, :proportion_rate, :proportion_amount)
    headers
    address = @session.address


    ledger = Ledger.new(request)
    ledger.address = address
    # 以下に移行してテストも書く
    # view/forms/ledger
    view = Views::LedgerForm.new
    @forms = view.form
    unless ledger.valid?
      view.execute(ledger: ledger)
      @forms = view.form
      @ledger = ledger
      assign_screen_items
      render :new
      return
    end
    ledger.recorded_amount = ledger.calculate_recorded_amount
    ledger.save

    redirect_to ledgers_path
  end

  def destroy_multiple
    headers
    address = @session.address

    ledger_ids = params[:ledger_ids]

    # jsでチェックするのでledger_idsのチェックは不要
    address.ledgers.where(id: ledger_ids).destroy_all

    redirect_to ledgers_path
  end

  def csv_upload_new
    headers
    @import_file = ImportFile.new
  end

  # csv_uploadは基本同じ処理なので、次の処理を作る際はモジュール化した方が良い。
  def csv_upload
    headers
    address = @session.address

    file = params[:import_file][:file]

    unless file.present?
      redirect_to csv_upload_new_ledgers_path, flash: { errors: [ "uploadファイルが存在しません。ファイルを選択ボタンからファイルを選択してください" ] }
      nil
    end

    ledger_file = FileUploads::Ledgers::File.new(address: address, file: file)

    # ユーザーのUXを考えて軽いチェックは同期でやる
    errors = ledger_file.validate_errors_first
    if errors.present?
      # ここでエラー一覧に遷移するべき
      flash[:errors] = errors
      render :csv_upload
      return
    end

    # import_fileデータの作成
    import_file = ledger_file.create_import_file

    # ここから非同期処理
    begin
      LedgerCsvImportJob.perform_later(import_file_id: import_file.id)
    rescue => e
      logger.error "LedgerCsvImportJobに失敗しました: #{e}"
      nil
      # TODO
      # ログを解析して拾えること
      # https://zenn.dev/greendrop/articles/2024-11-07-de79415b55bff0
    end
  end

  private

  def assign_screen_items
    @ledger_items = LedgerItem.all
  end
end
