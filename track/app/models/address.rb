class Address < ApplicationRecord
  has_many :transaction_types
  has_many :dollar_yen_transactions
end
