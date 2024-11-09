class TransactionType < ApplicationRecord
  enum :kind, { deposit: 1, withdrawal: 2 }
  belongs_to :address
  has_many :dollar_yen_transactions
end
