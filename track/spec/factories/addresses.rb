FactoryBot.define do
  factory :addresses_eth, class: Address do
    address { "0x00001E868c62FA205d38BeBaB7B903322A4CC89D" }
    kind { 1 }
  end

  factory :addresses_solana, class: Address do
    address { "ox555666" }
    kind { 2 }
  end
end
