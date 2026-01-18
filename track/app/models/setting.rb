class Setting < ApplicationRecord
  LANGUAGE_JA = "ja"

  belongs_to :address
end
