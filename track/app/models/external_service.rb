class ExternalService < ApplicationRecord
  SUMISHIN_SBI_NYUSHUKINMEISAI = 1

  has_many :external_service_transaction_types, dependent: :destroy
  # このサービスを利用しているTransactionTypeを直接参照したい場合
  has_many :transaction_types, through: :external_service_transaction_types
end
