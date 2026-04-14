FactoryBot.define do
  factory :blockchains_order do
    chain_id { "MyString" }
    tx_hash { "MyString" }
    from_address { "MyString" }
    to_address { "MyString" }
    block_number { 1 }
    amount { "9.99" }

    # 関連するモデルを自動生成
    association :order
  end
end
