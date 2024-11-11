class Address < ApplicationRecord
  enum :kind, { ethereum: 1, solana: 2 }
  has_many :transaction_types
  has_many :dollar_yen_transactions
end
