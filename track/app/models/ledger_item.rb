class LedgerItem < ApplicationRecord
  # 国民年金保険料
  ID_NATIONAL_PENSION_INSURANCE_PREMIUM = 5
  # 国民健康保険料
  ID_NATIONAL_HEALTH_INSURANCE = 6
  # 確定拠出年金
  ID_DC = 7
  # 小規模共済
  ID_SMALL_BUSINESS_MUTUAL_AID = 8
  # 予定納税第1期
  ID_FIRST_ESTIMATED_INCOME_TAX_PREPAYMENT = 10
  # 予定納税第2期
  ID_SECOND_ESTIMATED_INCOME_TAX_PREPAYMENT = 11

  enum :kind, { account_item: 1, drawings: 2 }
end
