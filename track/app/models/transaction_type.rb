class TransactionType < ApplicationRecord
  enum :kind, { deposit: 1, withdrawal: 2 }
  belongs_to :address
  has_many :dollar_yen_transactions

  def kind_name
    if deposit?
      return "預入"
    elsif withdrawal?
      return "払出"
    end
    nil
  end
end
