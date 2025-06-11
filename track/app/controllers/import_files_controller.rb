class ImportFilesController < ApplicationViewController
  before_action :verify, only: [ :index ]

  DEFAULT_LIMIT = 50
  DEFAULT_OFFSET = 0

  def index
    # default
    limit = params[:limit]
    limit = DEFAULT_LIMIT unless limit.present?

    offset = params[:offset]
    offset = DEFAULT_OFFSET unless offset.present?

    header_session

    session = find_session_by_cookie

    base_sql = session.address.import_files

    @total = base_sql.all.count
    @import_files = base_sql.order(created_at: :desc).map do |import_file|
      {
        id: import_file.id,
        date: import_file.created_at.strftime("%Y/%m/%d %H:%M:%S"),
        job_name: import_file.job.name,
        status: import_file.status_on_screen
      }
    end
  end

  def header_session
    @user = user
    @notification = notification
  end
end
