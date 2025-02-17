FactoryBot.define do
  factory :import_file, class: ImportFile do
    job { }
    address { }
    status { ImportFile.statuses[:ready] }
  end

  factory :import_file_in_progress, class: ImportFile do
    job { }
    address { }
    status { ImportFile.statuses[:in_progress] }
  end

  factory :import_file_completed, class: ImportFile do
    job { }
    address { }
    status { ImportFile.statuses[:completed] }
  end

  factory :import_file_failure, class: ImportFile do
    job { }
    address { }
    status { ImportFile.statuses[:failure] }
  end
end
