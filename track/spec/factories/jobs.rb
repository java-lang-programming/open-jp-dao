FactoryBot.define do
  factory :job_1, class: Job do
    name { "ドル円csvimport" }
    summary { "ドル円のcsvをimportします" }
  end

  factory :job_2, class: Job do
    name { "ドル円取引csvimport" }
    summary { "ドル円取引のcsvをimportします" }
  end
end
