class Address < ApplicationRecord
  enum :kind, { ethereum: 1, solana: 2 }
  has_many :transaction_types, dependent: :destroy
  has_many :dollar_yen_transactions, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :address, presence: true

  class << self
    def kind_errors(kind: nil)
      errors = []
      unless kind.present?
        errors << "kindは必須入力です"
      else
        unless Address.kinds.values.include?(kind.to_i)
          errors << "kindが不正な値です"
        end
      end
      errors
    end
  end
end
