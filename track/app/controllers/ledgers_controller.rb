class LedgersController < ApplicationViewController
  before_action :verify, only: [ :index, :csv_upload_new, :csv_upload ]

  def index
    headers
    address = @session.address


    # デフォルトはその年だけ
    # DBの保存方法には気をつける。昔のはあまり見られないはずなので。。。
    # 検索表示用
    base_sql = address.ledgers.preload(:ledger_item)
    puts base_sql.inspect
  end

  def csv_upload_new
    headers
  end

  def csv_upload
    headers

    file = params[:file]

    unless file.present?
      # jsのチェックがあれば来ないはず
      redirect_to csv_upload_new_path, flash: { errors: [ "uploadファイルが存在しません。ファイルを選択ボタンからファイルを選択してください" ] }
      nil
    end

    service = FileUploads::LedgerCsv.new(address: address, file: file)
    errors = service.validation_errors
    if errors.present?
      # ここでエラー一覧に遷移するべき
      redirect_to csv_upload_dollar_yen_transactions_path, flash: { errors: errors }
      # render json: { errors: errors }, status: :bad_request
      nil
    end
  end
end
