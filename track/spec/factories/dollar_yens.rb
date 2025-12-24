FactoryBot.define do
  factory :dollar_yen_20241218, class: DollarYen do
    date { "2024/12/18" }
    dollar_yen_nakane { 153.74 }
  end

  factory :dollar_yen_20241219, class: DollarYen do
    date { "2024/12/19" }
    dollar_yen_nakane { 154.94 }
  end

  factory :dollar_yen_20251001, class: DollarYen do
    date { "2025/10/01" }
    dollar_yen_nakane { 148.17 }
  end
end
