FactoryBot.define do
  factory :csv_ledger_item_1, class: CsvLedgerItem do
    ledger_item {  }
    csv { }
    content { 'ネン２キ　シヨトク' }
    exact_match { CsvLedgerItem::EXACT_MATCH_FALSE }
    proportion_rate {  }
    proportion_amount {  }
  end
  factory :csv_ledger_item_2, class: CsvLedgerItem do
    ledger_item {  }
    csv { }
    content { 'コクミンネンキン' }
    exact_match { CsvLedgerItem::EXACT_MATCH_TRUE }
    proportion_rate {  }
    proportion_amount {  }
  end
end
