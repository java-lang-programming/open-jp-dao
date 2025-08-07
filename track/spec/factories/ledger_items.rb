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
    id { 4 }
    name { "新聞図書費" }
    kind { LedgerItem.kinds[:account_item] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_5, class: LedgerItem do
    id { 5 }
    name { "国民年金保険料" }
    kind { LedgerItem.kinds[:drawings] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_6, class: LedgerItem do
    id { 6 }
    name { "国民健康保険料" }
    kind { LedgerItem.kinds[:drawings] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_7, class: LedgerItem do
    id { 7 }
    name { "確定拠出年金" }
    kind { LedgerItem.kinds[:drawings] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_8, class: LedgerItem do
    id { 8 }
    name { "小規模企業共済" }
    kind { LedgerItem.kinds[:drawings] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_9, class: LedgerItem do
    id { 9 }
    name { "為替差益" }
    kind { LedgerItem.kinds[:account_item] }
    summary { }
    deleted_at { }
  end

  factory :ledger_item_10, class: LedgerItem do
    id { 10 }
    name { "予定納税第1期" }
    kind { LedgerItem.kinds[:drawings] }
    summary { }
    deleted_at { }
  end
end
