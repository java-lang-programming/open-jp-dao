class TransactionType < ApplicationRecord
  enum :kind, { deposit: 1, withdrawal: 2 }
  belongs_to :address
  has_many :dollar_yen_transactions

  DEPOSIT_NAME = "入金"
  WITHDRAWAL_NAME = "出金"

  def kind_name
    if deposit?
      return TransactionType::DEPOSIT_NAME
    elsif withdrawal?
      return TransactionType::WITHDRAWAL_NAME
    end
    nil
  end

  def self.kinds_collection
    [
      { id: TransactionType.kinds[:deposit], name: TransactionType::DEPOSIT_NAME },
      { id: TransactionType.kinds[:withdrawal], name: TransactionType::WITHDRAWAL_NAME }
    ]
  end
end
