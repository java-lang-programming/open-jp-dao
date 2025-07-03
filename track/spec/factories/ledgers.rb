FactoryBot.define do
  factory :ledger do
    date { "2025-06-25 09:10:29" }
    name { "MyString" }
    ledgers_item_id { 1 }
    face_value { "9.99" }
    proportion_rate { "9.99" }
    proportion_amount { "9.99" }
    recorded { "9.99" }
  end
end
