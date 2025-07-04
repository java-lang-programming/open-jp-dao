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

  # csv_uploadは基本同じ処理なので、次の処理を作る際はモジュール化した方が良い。
  def csv_upload
    headers
    address = @session.address

    # 　TODO 現在処理している非同期処理がある場合は実行しない

    file = params[:file]

    unless file.present?
      # jsのチェックがあれば来ないはず
      redirect_to csv_upload_new_path, flash: { errors: [ "uploadファイルが存在しません。ファイルを選択ボタンからファイルを選択してください" ] }
      nil
    end

    ledger_csv = FileUploads::LedgerCsv.new(address: address, file_path: file)
    # headerとbodyの思い処理以外の簡単なチェックを行う
    # ユーザーのUXを考えて軽いチェックは同期でやる
    errors = ledger_csv.validate_errors_first
    if errors.present?
      # ここでエラー一覧に遷移するべき
      redirect_to csv_upload_dollar_yen_transactions_path, flash: { errors: errors }
      # render json: { errors: errors }, status: :bad_request
      nil
    end

    # import_fileデータの作成
    ledger_csv.create_import_file

    # ここから非同期処理
    begin
      LedgerCsvImportJob.perform_later(ledger_csv: ledger_csv)
    rescue => e
      logger.error "LedgerCsvImportJobに失敗しました: #{e}"
      nil
      # TODO
      # ログを解析して拾えること
      # https://zenn.dev/greendrop/articles/2024-11-07-de79415b55bff0
    end
  end
end
