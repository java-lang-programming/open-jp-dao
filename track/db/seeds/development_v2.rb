csv = Csv.find(Csv::ID_UFJ)
rakuten_csv = Csv.find(Csv::ID_RAKUTEN_CARD)

# TODO 紐づくユーザーidが必要

# ネン２キ　シヨトク
second_estimated_income_tax_prepayment = LedgerItem.find_or_create_by(id: LedgerItem::ID_SECOND_ESTIMATED_INCOME_TAX_PREPAYMENT)

second_estimated_income_tax_prepayment.csv_ledger_items.create!(
  csv: csv,
  content:  'ネン２キ　シヨトク',
  exact_match: CsvLedgerItem::EXACT_MATCH_FALSE
)

# 国民年金保険料
pension_insurance_premium = LedgerItem.find_or_create_by(id: LedgerItem::ID_NATIONAL_PENSION_INSURANCE_PREMIUM)

pension_insurance_premium.csv_ledger_items.create!(
  csv: csv,
  content:  'コクミンネンキン',
  exact_match: CsvLedgerItem::EXACT_MATCH_TRUE
)

# 国民健康保険
national_health_insurance = LedgerItem.find_or_create_by(id: LedgerItem::ID_NATIONAL_HEALTH_INSURANCE)

national_health_insurance.csv_ledger_items.create!(
  csv: csv,
  content:  'コクミンケンコウホケン',
  exact_match: CsvLedgerItem::EXACT_MATCH_TRUE
)

# 確定拠出年金
dc = LedgerItem.find_or_create_by(id: LedgerItem::ID_DC)

dc.csv_ledger_items.create!(
  csv: csv,
  content:  'カクテイキヨシユツカケキ',
  exact_match: CsvLedgerItem::EXACT_MATCH_TRUE
)

# シヨウキボキヨウサイ
small_business_mutual_aid = LedgerItem.find_or_create_by(id: LedgerItem::ID_SMALL_BUSINESS_MUTUAL_AID)

small_business_mutual_aid.csv_ledger_items.create!(
  csv: csv,
  content:  'シヨウキボキヨウサイ',
  exact_match: CsvLedgerItem::EXACT_MATCH_TRUE
)

sales = LedgerItem.find_or_create_by(id: LedgerItem::ID_SALES)

sales.csv_ledger_items.create!(
  csv: csv,
  content: 'カ）モンスタ－ラボ',
  exact_match: CsvLedgerItem::EXACT_MATCH_TRUE
)

puts "ユーザーに紐づくufj csvデータの投入完了"

puts "ユーザーに紐づく楽天csvデータ投入"

communication_expenses = LedgerItem.find_or_create_by(id: LedgerItem::ID_COMMUNICATION_EXPENSES)

communication_expenses.csv_ledger_items.create!(
  csv: rakuten_csv,
  content: 'ＮＴＴ東日本光コラボ回収',
  exact_match: CsvLedgerItem::EXACT_MATCH_FALSE,
  proportion_rate: 0.8,
  proportion_amount: 825
)

communication_expenses.csv_ledger_items.create!(
  csv: rakuten_csv,
  content: 'ｿﾌﾄﾊﾞﾝｸM',
  exact_match: CsvLedgerItem::EXACT_MATCH_FALSE,
  proportion_rate: 0.8
)

utility_bills = LedgerItem.find_or_create_by(id: LedgerItem::ID_UTILITY_BILLS)

utility_bills.csv_ledger_items.create!(
  csv: rakuten_csv,
  content: 'ＥＮＥＯＳ　Ｐｏｗｅｒ（電気）',
  exact_match: CsvLedgerItem::EXACT_MATCH_TRUE,
  proportion_rate: 0.8,
  proportion_amount: 825
)
