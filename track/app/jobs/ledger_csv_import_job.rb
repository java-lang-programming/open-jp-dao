# 　レビューにかける
class LedgerCsvImportJob < ApplicationJob
  queue_as :csv

  # LedgerCsvにエラーがある
  class LedgerCsvErrors < StandardError; end

  def perform(ledger_csv:)
    begin
      # 実行中にする
      ledger_csv.update_status(status: :in_progress)

      errors = ledger_csv.validate_errors_of_complex_data
      if errors.present?
        # ここでエラーデータを保存する
        raise LedgerCsvErrors unless @session.present?
      end

      # 　オブジェクトの生成
      ledgers = ledger_csv.generate_ledgers

      # bulk insert
      Ledger.import ledgers, validate: true

      # ステータスを成功
      ledger_csv.update_status(status: :completed)
    rescue => e
      # ステータスを失敗
      ledger_csv.update_status(status: :failure)
      Rails.error.report(e)
    ensure
      # ファイルの保存は不要なので削除
      ledger_csv.purge_file
    end
  end
end
