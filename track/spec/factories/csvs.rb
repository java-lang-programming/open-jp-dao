FactoryBot.define do
  factory :csv_1, class: Csv do
    id { Csv::ID_UFJ }
    name { "UFJ" }
  end

  factory :csv_2, class: Csv do
    id { Csv::ID_RAKUTEN_CARD }
    name { "楽天カード" }
  end
end
