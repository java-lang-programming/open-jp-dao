FactoryBot.define do
  factory :ledger_item_1, class: LedgerItem do
    id { 1 }
    name { "通信費" }
    kind { LedgerItem.kinds[:account_item] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_2, class: LedgerItem do
    id { 2 }
    name { "水道光熱費" }
    kind { LedgerItem.kinds[:account_item] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_3, class: LedgerItem do
    id { 3 }
    name { "消耗品費" }
    kind { LedgerItem.kinds[:account_item] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_4, class: LedgerItem do
    id { 3 }
    name { "新聞図書費" }
    kind { LedgerItem.kinds[:account_item] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_5, class: LedgerItem do
    id { 3 }
    name { "国民年金保険料" }
    kind { LedgerItem.kinds[:drawings] }
    summary { }
    deleted_at { }
  end
end
