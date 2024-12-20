class Apis::DollarYensController < ApplicationController
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

    begin
      DollarYenCsvImportJob.perform_later(file_path: file)
    rescue => e
      puts e
      # TODO log
      # 　ログを解析して拾えること
      # https://zenn.dev/greendrop/articles/2024-11-07-de79415b55bff0
    end

    render status: :created
  end
end
