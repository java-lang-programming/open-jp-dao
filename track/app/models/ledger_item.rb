class LedgerItem < ApplicationRecord
  # 国民年金保険料
  ID_NATIONAL_PENSION_INSURANCE_PREMIUM = 5
  # 国民健康保険料
  ID_NATIONAL_HEALTH_INSURANCE = 6
  # 小規模共済
  ID_SMALL_BUSINESS_MUTUAL_AID = 8


  enum :kind, { account_item: 1, drawings: 2 }
end
