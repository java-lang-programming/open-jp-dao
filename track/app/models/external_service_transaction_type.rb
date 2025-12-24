class ExternalServiceTransactionType < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }

  belongs_to :external_service
  belongs_to :transaction_type
end
