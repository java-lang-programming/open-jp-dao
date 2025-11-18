class ImportFilesController < ApplicationViewController
  before_action :verify, only: [ :index, :result ]

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
    @import_files = base_sql.limit(limit).offset(offset).order(created_at: :desc).map do |import_file|
      {
        id: import_file.id,
        date: import_file.created_at.strftime("%Y/%m/%d %H:%M:%S"),
        job_name: import_file.job.name,
        status: import_file.status
      }
    end
  end

  def result
    headers
    address = @session.address

    id = params[:id]

    @import_file = address.import_files.where(id: id).first

    unless @import_file.present?
      raise NotFoundData
    end

    if @import_file.job.id == Job::DOLLAR_YENS_TRANSACTIONS_CSV_IMPORT
      @import_file.set_target_path(target_path: dollar_yen_transactions_path)
    end
  end

  def header_session
    @user = user
    @notification = notification
  end
end
