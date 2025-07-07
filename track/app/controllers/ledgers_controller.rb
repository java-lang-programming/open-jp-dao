class LedgersController < ApplicationViewController
  before_action :verify, only: [ :index, :csv_upload_new, :csv_upload ]

  DEFAULT_LIMIT = 50

  def index
    request = params.permit(:page)

    headers
    address = @session.address


    # デフォルトはその年だけ
    # DBの保存方法には気をつける。昔のはあまり見られないはずなので。。。
    # 検索表示用
    base_sql = address.ledgers.preload(:ledger_item)
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

  def csv_upload_new
    headers
    @import_file = ImportFile.new
  end

  # csv_uploadは基本同じ処理なので、次の処理を作る際はモジュール化した方が良い。
  def csv_upload
    headers
    address = @session.address

    # 　TODO 現在処理している非同期処理がある場合は実行しない

    # file = params[:file]
    # file = params.require(:import_file).permit(:file)
    file = params[:import_file][:file]

    # @image = ImportFile.new(image_params)

    unless file.present?
      # jsのチェックがあれば来ないはず
      redirect_to csv_upload_new_ledgers_path, flash: { errors: [ "uploadファイルが存在しません。ファイルを選択ボタンからファイルを選択してください" ] }
      nil
    end

    # uploaded_file = file[:file]
    ledger_file = FileUploads::Ledgers::File.new(address: address, file: file)

    # ledger_csv = FileUploads::LedgerCsv.new(address: address, file: file)
    # headerとbodyの思い処理以外の簡単なチェックを行う
    # ユーザーのUXを考えて軽いチェックは同期でやる
    errors = ledger_file.validate_errors_first
    if errors.present?
      # ここでエラー一覧に遷移するべき
      redirect_to csv_upload_dollar_yen_transactions_path, flash: { errors: errors }
      # render json: { errors: errors }, status: :bad_request
      nil
    end

    # import_fileデータの作成
    import_file = ledger_file.create_import_file

    # ここから非同期処理
    begin
      # LedgerCsvImportJob.perform_later(ledger_csv: ledger_csv)
      LedgerCsvImportJob.perform_later(import_file_id: import_file.id)
    rescue => e
      logger.error "LedgerCsvImportJobに失敗しました: #{e}"
      nil
      # TODO
      # ログを解析して拾えること
      # https://zenn.dev/greendrop/articles/2024-11-07-de79415b55bff0
    end
  end
end
