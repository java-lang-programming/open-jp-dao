module Nav
  EXCHANGE_GAIN_AND_LOSSES = 1
  DOLLAR_YEN_TRANSACTION = 2
  TRANSACTION_TYPE = 3

  TAX_RESULT = 1
  LEDGERS = 2

  ACCOUNT = 1

  def transactions_navs(selected: EXCHANGE_GAIN_AND_LOSSES)
    [
      { id: 1, name: I18n.t("header.nav.dollar_yen_transactions.exchange"), path: foreign_exchange_gain_dollar_yen_transactions_path, selected: selected == 1 },
      { id: 2, name: I18n.t("header.nav.dollar_yen_transactions.ledger"), path: dollar_yen_transactions_path, selected: selected == 2 },
      { id: 3, name: I18n.t("header.nav.dollar_yen_transactions.type"), path: transaction_types_path, selected: selected == 3 }
    ]
  end

  def ledgers_navs(selected: TAX_RESULT)
    [
      { id: 1, name: "仕訳結果", path: tax_returns_path, selected: selected == 1 },
      { id: 2, name: "仕訳帳", path: ledgers_path, selected: selected == 2 }
    ]
  end

  def settings_navs(selected: ACCOUNT)
    [
      { id: 1, name: "アカウント", path: settings_path, selected: selected == 1 }
    ]
  end
end
