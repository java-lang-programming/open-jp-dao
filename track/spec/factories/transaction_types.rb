FactoryBot.define do
  factory :transaction_type1, class: TransactionType do
    name { "HDV配当入金" }
    kind { 1 }
    address { }
  end

  factory :transaction_type2, class: TransactionType do
    name { "住信SBI利子" }
    kind { 1 }
    address { }
  end

  factory :transaction_type3, class: TransactionType do
    name { "VYM配当入金" }
    kind { 1 }
    address { }
  end

  factory :transaction_type5, class: TransactionType do
    name { "ドルを円に変換" }
    kind { 2 }
    address { }
  end
end
