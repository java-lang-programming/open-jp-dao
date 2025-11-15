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
    summary { '国民年金の支払い' }
    deleted_at { }
  end

  factory :ledger_item_6, class: LedgerItem do
    id { 6 }
    name { "国民健康保険料" }
    kind { LedgerItem.kinds[:drawings] }
    summary { '国民健康保険の支払い' }
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
    summary { '小規模企業の経営者や役員、個人事業主などのための、積み立てによる退職金制度です。'}
    deleted_at { }
  end

  factory :ledger_item_9, class: LedgerItem do
    id { 9 }
    name { "為替差益" }
    kind { LedgerItem.kinds[:account_item] }
    summary { '外貨建の取引では、取引時と決済時、あるいは外貨建債権等を決算時のレートで換算した時に円と外国通貨の為替レートが異なることにより益や損が発生します。 為替差益は、この為替レートによる損益を計上します。 期中の収益合計と損失合計を相殺して、益がでた場合は「為替差益」に、損がでた場合は「為替差損」に計上します。' }
    deleted_at { }
  end

  factory :ledger_item_10, class: LedgerItem do
    id { 10 }
    name { "予定納税第1期" }
    kind { LedgerItem.kinds[:drawings] }
    summary { '前年分の所得金額や税額などを基に計算した予定納税基準額が15万円以上となる場合には、原則、この予定納税基準額の３分の１相当額をそれぞれ７月(第１期分)と11月(第２期分)に納めることとなっています。 この制度を「予定納税」といいます。' }
    deleted_at { }
  end

  factory :ledger_item_11, class: LedgerItem do
    id { 11 }
    name { "予定納税第2期" }
    kind { LedgerItem.kinds[:drawings] }
    summary { '前年分の所得金額や税額などを基に計算した予定納税基準額が15万円以上となる場合には、原則、この予定納税基準額の３分の１相当額をそれぞれ７月(第１期分)と11月(第２期分)に納めることとなっています。 この制度を「予定納税」といいます。' }
    deleted_at { }
  end

  factory :ledger_item_12, class: LedgerItem do
    id { 12 }
    name { "雑収入" }
    kind { LedgerItem.kinds[:drawings] }
    summary {  }
    deleted_at { }
  end
end
