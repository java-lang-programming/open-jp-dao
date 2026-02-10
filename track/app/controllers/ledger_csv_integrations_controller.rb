class LedgerCsvIntegrationsController < ApplicationViewController
  include Nav
  before_action :verify, only: [ :ufj_csv_upload_new, :ufj_csv_upload ]

  def ufj_csv_upload_new
    headers
    @navs = ledgers_navs(selected: LEDGERS)
    @import_file = ImportFile.new
  end

  def ufj_csv_upload
    headers
    address = @session.address
    @navs = ledgers_navs(selected: LEDGERS)

    file = params[:import_file][:file]

    unless file.present?
      @import_file = ImportFile.new
      flash.now[:notice] = "uploadファイルが存在しません。ファイルを選択ボタンからファイルを選択してください"
      render :ufj_csv_upload_new, status: :unprocessable_content # redirectではなくrender
      return
    end

    ufj_file = FileUploads::Ledgers::UfjFile.new(address: address, file: file)
    errors = ufj_file.validate_headers
    if errors.present?
      @import_file = ImportFile.new
      flash.now[:errors] = errors
      render :ufj_csv_upload_new, status: :unprocessable_entity # redirectではなくrender
      return
    end

    # import_fileデータの作成
    import_file = ufj_file.create_import_file

    # ここから非同期処理
    begin
      UfjLedgerCsvImportJob.perform_later(import_file_id: import_file.id)
    rescue => e
      logger.error "LedgerCsvImportJobに失敗しました: #{e}"
      nil
    end
  end
end
