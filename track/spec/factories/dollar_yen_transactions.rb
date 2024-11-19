FactoryBot.define do
  factory :dollar_yen_transaction1, class: DollarYenTransaction do
    transaction_type { }
    date { '2020-04-01' }
    deposit_rate { 106.59 }
    deposit_quantity { 3.97 }
    deposit_en { 423 }
    balance_quantity { 3.97 }
    balance_rate { 106.5491184 }
    balance_en { 423 }
    address { }
  end

  factory :dollar_yen_transaction2, class: DollarYenTransaction do
    transaction_type { }
    date { '2020-06-19' }
    deposit_rate { 105.95 }
    deposit_quantity { 10.76 }
    deposit_en { 1140 }
    balance_quantity { 14.73 }
    balance_rate { 106.1099796 }
    balance_en { 1563 }
    address { }
  end

  factory :dollar_yen_transaction3, class: DollarYenTransaction do
    transaction_type { }
    date { '2020-09-29' }
    deposit_rate { 104.35 }
    deposit_quantity { 14.73 }
    deposit_en { 1537 }
    balance_quantity { 29.46 }
    balance_rate { 105.227427 }
    balance_en { 3100 }
    address { }
  end

  factory :dollar_yen_transaction43, class: DollarYenTransaction do
    transaction_type { }
    date { '2024-01-21' }
    deposit_rate { 148.19 }
    deposit_quantity { 0.18 }
    deposit_en { 26 }
    balance_quantity { 745.88 }
    balance_rate { 137.0555585 }
    balance_en { 102227 }
    address { }
  end

  factory :dollar_yen_transaction44, class: DollarYenTransaction do
    transaction_type { }
    date { '2024-02-01' }
    deposit_rate { nil }
    deposit_quantity { nil }
    deposit_en { nil }
    withdrawal_rate { 137.0555585 }
    withdrawal_quantity { 88 }
    withdrawal_en { 12060.88915 }
    exchange_en { 12918 }
    exchange_difference { 857 }
    balance_quantity { 657.88 }
    balance_rate { 137.0569101 }
    balance_en { 90166.11085 }
    address { }
  end
end
