FactoryBot.define do
  factory :csv_1, class: Csv do
    id { Csv::ID_UFJ }
    name { "UFJ" }
  end
end
