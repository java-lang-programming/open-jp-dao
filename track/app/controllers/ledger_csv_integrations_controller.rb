class LedgerCsvIntegrationsController < ApplicationViewController
  include Nav
  before_action :verify, only: [ :ufj_csv_upload_new, :ufj_csv_upload ]

  def ufj_csv_upload_new
    csv_upload_new
  end

  def ufj_csv_upload
    headers
    address = @session.address
    @navs = ledgers_navs(selected: LEDGERS)

    file = params.dig(:import_file, :file)

    return if file_empty?(file: file, template: :ufj_csv_upload_new)

    return unless file_valid_encode?(file: file, template: :ufj_csv_upload_new)

    ufj_file = FileUploads::Ledgers::UfjFile.new(address: address, file: file)
    errors = ufj_file.validate_headers
    if errors.present?
      @import_file = ImportFile.new
      flash.now[:errors] = errors
      render :ufj_csv_upload_new, status: :unprocessable_entity
      return
    end

    # import_fileデータの作成
    import_file = ufj_file.create_import_file

    # ここから非同期処理
    begin
      UfjLedgerCsvImportJob.perform_later(import_file_id: import_file.id)
    rescue => e
      logger.error "LedgerCsvImportJobに失敗しました: #{e}"
    end
  end

  def rakuten_card_csv_upload_new
    csv_upload_new
  end

  def rakuten_card_csv_upload
    headers
    address = @session.address
    @navs = ledgers_navs(selected: LEDGERS)

    file = params.dig(:import_file, :file)

    return if file_empty?(file: file, template: :rakuten_card_csv_upload_new)

    return unless file_valid_encode?(file: file, template: :rakuten_card_csv_upload_new)

    rakuten_card_file = FileUploads::Ledgers::RakutenCardFile.new(address: address, file: file)
    errors = rakuten_card_file.validate_headers
    if errors.present?
      @import_file = ImportFile.new
      flash.now[:errors] = errors
      render :rakuten_card_csv_upload_new, status: :unprocessable_entity
      nil
    end

    # import_fileデータの作成
    import_file = rakuten_card_file.create_import_file

    # ここから非同期処理
    begin
      RakutenCardLedgerCsvImportJob.perform_later(import_file_id: import_file.id)
    rescue => e
      logger.error "LedgerCsvImportJobに失敗しました: #{e}"
    end
  end

  private

    def csv_upload_new
      headers
      @navs = ledgers_navs(selected: LEDGERS)
      @import_file = ImportFile.new
    end

    def flash_notice(msg:, template:)
      @import_file = ImportFile.new
      flash.now[:notice] = msg
      render template, status: :unprocessable_content # redirectではなくrender
    end

    def file_empty?(file:, template:)
      return false if file.present?

      flash_notice(
        msg: "uploadファイルが存在しません。ファイルを選択ボタンからファイルを選択してください",
        template: template
      )

      true
    end


    def file_valid_encode?(file:, template:)
      return true if File.read(file.path).force_encoding("UTF-8").valid_encoding?

      flash_notice(
        msg: "CSVの文字コードが不正です。UTF-8形式で保存し直してからアップロードしてください",
        template: template
      )

      false
    end
end
