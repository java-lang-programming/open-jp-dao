# 　ドル円取引の更新
# TODO テスト
class DollarYenTransactionsUpdateJob < ApplicationJob
  queue_as :csv

  rescue_from(Exception) do |exception|
    Rails.error.report(exception)
    raise exception
  end

  def perform(dollar_yen_transaction:, kind:)
    begin
      dollar_yens_transactions = dollar_yen_transaction.generate_upsert_dollar_yens_transactions(kind: kind)
      # ここからトランザクション
      ActiveRecord::Base.transaction do
        dollar_yen_transaction.destroy if kind == "delete"
        DollarYenTransaction.import dollar_yens_transactions, on_duplicate_key_update: { conflict_target: [ :id ], columns: [ :deposit_rate, :deposit_quantity, :deposit_en, :balance_rate, :balance_quantity, :balance_en ] },  validate: true
      end
    rescue => e
      puts e
      Rails.error.report(e)
    end
  end
end
