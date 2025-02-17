class Apis::Dollaryen::DownloadsController < ApplicationController
  before_action :verify_v2, only: [ :show ]

  def show
    id = params[:id]
    return :bad_request unless id == "csv_import" || id == "csv_export"

    session = find_session_by_cookie
    address = session.address

    send_data(
      data(address: address, id: id),
      filename: address.make_file_name,
      disposition: "attachment",
      type: :csv
    )
  end

  def data(address:, id:)
    if id == "csv_import"
      address.generate_dollar_yen_transactions_csv_import_data
    elsif id == "csv_export"
      address.generate_dollar_yen_transactions_csv_export_import_data
    else
      # 絶対にここには来ない
      nil
    end
  end
end
