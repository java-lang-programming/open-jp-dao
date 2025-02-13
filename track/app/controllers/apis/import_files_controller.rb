class Apis::ImportFilesController < ApplicationController
  before_action :verify_v2, only: [ :index ]

  def index
    limit = params[:limit]
    limit = 50 unless limit.present?
    offset = params[:offset]
    offset = 0 unless offset.present?

    session = find_session_by_cookie
    base_sql = session.address.import_files
    total = base_sql.all.count
    import_files = base_sql.limit(limit).offset(offset).order(created_at: :desc)

    # エラーに関しては後で
    responses = import_files.map do |import_file|
      {
        id: import_file.id,
        date: import_file.created_at.strftime("%Y/%m/%d"),
        job_name: import_file.job.name,
        status: import_file.status
      }
    end
    render json: { total: total, import_files: responses }, status: :ok
  end
end
