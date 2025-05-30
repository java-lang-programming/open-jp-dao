FactoryBot.define do
  factory :dollar_yen_transaction1, class: DollarYenTransaction do
    transaction_type { }
    date { '2020-04-01' }
    deposit_rate { 106.59 }
    deposit_quantity { 3.97 }
    deposit_en { 423 }
    balance_quantity { 3.97 }
    balance_rate { 106.5491183879093 }
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
    balance_rate { 106.1099796334012 }
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
    balance_rate { 105.2274270196877 }
    balance_en { 3100 }
    address { }
  end

  factory :dollar_yen_transaction4, class: DollarYenTransaction do
    transaction_type { }
    date { '2020-12-18' }
    deposit_rate { 102.26 }
    deposit_quantity { 20.61 }
    deposit_en { 2107 }
    balance_quantity { 50.07 }
    balance_rate { 103.9944078290393 }
    balance_en { 5207 }
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


  factory :dollar_yen_transaction51, class: DollarYenTransaction do
    transaction_type { }
    date { '2024-04-05' }
    deposit_rate { nil }
    deposit_quantity { nil }
    deposit_en { nil }
    withdrawal_rate { 133.378789 }
    withdrawal_quantity { 72.1 }
    withdrawal_en { 9616.610688 }
    exchange_en { 10930 }
    exchange_difference { 1313 }
    balance_quantity { 657.58 }
    balance_rate { 133.378789 }
    balance_en { 87707.22408 }
    address { }
  end
end
