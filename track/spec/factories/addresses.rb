FactoryBot.define do
  factory :addresses_eth, class: Address do
    address { "0x00001E868c62FA205d38BeBaB7B903322A4CC89D" }
    ens_name { }
    kind { Address.kinds[:ethereum] }

    # traitを定義
    trait :with_setting do
      after(:create) do |address|
        create(:setting, address: address, default_year: 2026)
      end
    end
  end

  factory :addresses_solana, class: Address do
    address { "ox555666" }
    kind {  Address.kinds[:solana] }
  end
end
