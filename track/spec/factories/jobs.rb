FactoryBot.define do
  factory :job_1, class: Job do
    id { Job::DOLLAR_YENS_CSV_IMPORT }
    name { "ドル円csvインポート" }
    summary { "ドル円のcsvをimportします" }
  end

  factory :job_2, class: Job do
    id { Job::DOLLAR_YENS_TRANSACTIONS_CSV_IMPORT }
    name { "ドル円取引csvインポート" }
    summary { "ドル円取引のcsvをimportします" }
  end

  factory :job_3, class: Job do
    id { Job::LEDGER_CSV_IMPORT }
    name { "仕訳帳csvインポート" }
    summary { "仕訳帳のcsvをimportします" }
  end
end
