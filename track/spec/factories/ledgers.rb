FactoryBot.define do
  factory :ledger_1, class: Ledger do
    date { "2025-01-06 09:10:29" }
    name { "MFクラウド" }
    ledger_item {  }
    face_value { 1848 }
    proportion_rate { 1 }
    proportion_amount {  }
    recorded_amount { 1848 }
    address { }
  end

  factory :ledger_2, class: Ledger do
    date { "2025-03-04 09:10:29" }
    name { "MFクラウド" }
    ledger_item {  }
    face_value { 1848 }
    proportion_rate { 1 }
    proportion_amount {  }
    recorded_amount { 1848 }
    address { }
  end

  factory :ledger_3, class: Ledger do
    date { "2025-04-04 09:10:29" }
    name { "MFクラウド" }
    ledger_item {  }
    face_value { 1848 }
    proportion_rate { 1 }
    proportion_amount {  }
    recorded_amount { 1848 }
    address { }
  end
end
