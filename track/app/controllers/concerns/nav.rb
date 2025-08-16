module Nav
  EXCHANGE_GAIN = 1
  DOLLAR_YEN_TRANSACTION = 2
  TRANSACTION_TYPE = 3

  TAX_RESULT = 1
  LEDGERS = 2

  def transactions_navs(selected: 1)
    [
      { id: 1, name: "為替差益", path: foreign_exchange_gain_dollar_yen_transactions_path, selected: selected == 1 },
      { id: 2, name: "ドル円外貨預金元帳", path: dollar_yen_transactions_path, selected: selected == 2 },
      { id: 3, name: "取引種類", path: transaction_types_path, selected: selected == 3 }
    ]
  end

  def ledgers_navs(selected: 1)
    [
      { id: 1, name: "仕訳結果", path: tax_returns_path, selected: selected == 1 },
      { id: 2, name: "仕訳帳", path: ledgers_path, selected: selected == 2 }
    ]
  end
end
