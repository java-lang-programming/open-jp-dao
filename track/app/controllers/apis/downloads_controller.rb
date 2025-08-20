class Apis::DownloadsController < ApplicationController
  def show
    filename = params[:filename]
    file_path = Rails.root.join("downloadable_files", filename)

    return render json: { error: "File not found" }, status: :not_found unless File.exist?(file_path)

    send_file file_path,
              filename: filename,
              type: "text/csv",
              disposition: "attachment"
  end

  # まだいらない
  # private

  #   def mime_type(filename)
  #     case File.extname(filename)
  #     when ".csv"
  #       "text/csv"
  #     # when ".xlsx"
  #     #   "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  #     # when ".xls"
  #     #   "application/vnd.ms-excel"
  #     else
  #       "application/octet-stream"
  #     end
  #   end
end
