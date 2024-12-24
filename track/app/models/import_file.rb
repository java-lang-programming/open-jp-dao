class ImportFile < ApplicationRecord
  belongs_to :address
  belongs_to :job

  has_one_attached :file
end
