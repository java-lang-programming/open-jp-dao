class Setting < ApplicationRecord
  LANGUAGE_JA = "ja"

  belongs_to :address

  validates :default_year,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 2000,
              less_than_or_equal_to: 2100
            }
end
