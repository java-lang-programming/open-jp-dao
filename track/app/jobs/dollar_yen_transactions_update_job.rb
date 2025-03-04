# 　ドル円取引の更新
class DollarYenTransactionsUpdateJob < ApplicationJob
  queue_as :csv

  rescue_from(Exception) do |exception|
    Rails.error.report(exception)
    raise exception
  end

  def perform(dollar_yen_transaction:)
    begin
      dollar_yens_transactions = dollar_yen_transaction.generate_upsert_dollar_yens_transactions
      DollarYenTransaction.import dollar_yens_transactions[:dollar_yens_transactions], on_duplicate_key_update: { conflict_target: [ :id ], columns: [ :deposit_rate, :deposit_quantity, :deposit_en, :balance_rate, :balance_quantity, :balance_en ] },  validate: true
    rescue => e
      Rails.error.report(e)
    end
  end
end
