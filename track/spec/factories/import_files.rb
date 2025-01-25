FactoryBot.define do
  factory :import_file, class: ImportFile do
    job { }
    address { }
    status { ImportFile.statuses[:ready] }
  end
end
