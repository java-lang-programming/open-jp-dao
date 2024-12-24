class Apis::DollarYensController < ApplicationController
  before_action :verify_v2, only: [ :csv_import ]

  # ドル円データ取得
  def index
    date = params[:date]

    base_dollar_yen = nil
    if date.present?
      base_dollar_yen = DollarYen.where(date: date)
      unless base_dollar_yen.present?
        render json: { errors: [ { msg: "dateのドル円データは存在しません" } ] }, status: :bad_request
        return
      end
    else
      base_dollar_yen = DollarYen.all
    end

    total = base_dollar_yen.count
    dollar_yens = base_dollar_yen.limit(20)

    responses = dollar_yens.map do |dy|
      {
        date: dy.formatted_date,
        dollar_yen_nakane: dy.formatted_dollar_yen_nakane
      }
    end
    render json: { total: total, dollar_yens: responses }, status: :ok
  end

  # csv import
  def csv_import
    file = params[:file]

    unless file.present?
      render json: { errors: [ { msg: "ファイルが存在しません" } ] }, status: :bad_request
      return
    end

    service = FileUploads::DollarYenCsv.new(file: file)
    errors = service.validation_errors
    if errors.present?
      render json: { errors: errors }, status: :bad_request
      return
    end

    session = find_session_by_cookie
    job = Job.find(Job::DOLLAR_YENS_CSV_IMPORT)
    address = Address.where(address: session.address.address).first


    # https://railsguides.jp/active_storage_overview.html
    # 保存 ステータスも。
    import_file = ImportFile.new(address: address, job: job)
    import_file.file.attach(file)
    import_file.save

    begin
      DollarYenCsvImportJob.perform_later(import_file_id: import_file.id)
    rescue => e
      logger.error "DollarYenCsvImportJobに失敗しました: #{e}"
      # ログを解析して拾えること
      # https://zenn.dev/greendrop/articles/2024-11-07-de79415b55bff0
    end

    render status: :created
  end
end
