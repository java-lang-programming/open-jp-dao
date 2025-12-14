# 　まずは仮で実装
module TaxReturns
  class Calculation
    attr_accessor :address, :year

    # 　yearはdefaultは現在日付
    def initialize(address: nil, year: nil)
      @address = address
      @year = year
    end

    def execute
      # これは共通化したいね
      start_date = Time.new(@year, 1, 1)
      end_date = Time.new(@year, 12, 31)
      base = @address.ledgers.where(date: (start_date..end_date))

      # 通信費
      communication_expense = base.where(ledger_item_id: 1).sum(:recorded_amount)
      # 水道光熱費
      utility_costs =  base.where(ledger_item_id: 2).sum(:recorded_amount)
      # 消耗品費
      supplies_expense = base.where(ledger_item_id: 3).sum(:recorded_amount)
      # 為替差益
      foreign_exchange_gain = @address.foreign_exchange_gain(year: @year)
      # 国民年金保険料
      supplies_national_pension_insurance_premium = base.where(ledger_item_id: LedgerItem::ID_NATIONAL_PENSION_INSURANCE_PREMIUM).sum(:recorded_amount)
      # 国民健康保険料
      national_health_insurance = base.where(ledger_item_id: LedgerItem::ID_NATIONAL_HEALTH_INSURANCE).sum(:recorded_amount)
      # 確定拠出年金
      dc = base.where(ledger_item_id: LedgerItem::ID_DC).sum(:recorded_amount)
      # 小規模共済
      small_business_mutual_aid = base.where(ledger_item_id: LedgerItem::ID_SMALL_BUSINESS_MUTUAL_AID).sum(:recorded_amount)
      # 予定納税第1期
      first_estimated_income_tax_prepayment = base.where(ledger_item_id: LedgerItem::ID_FIRST_ESTIMATED_INCOME_TAX_PREPAYMENT).sum(:recorded_amount)
      # 予定納税第2期
      second_estimated_income_tax_prepayment = base.where(ledger_item_id: LedgerItem::ID_SECOND_ESTIMATED_INCOME_TAX_PREPAYMENT).sum(:recorded_amount)
      # 雑収入
      miscellaneous_income = base.where(ledger_item_id: LedgerItem::ID_MISCELLANEOUS_INCOME).sum(:recorded_amount)
      # 売上高
      sales = base.where(ledger_item_id: LedgerItem::ID_SALES).sum(:recorded_amount)
      # 総額
      total = miscellaneous_income + sales
      {
        communication_expense: communication_expense,
        utility_costs: utility_costs,
        supplies_expense: supplies_expense,
        foreign_exchange_gain: foreign_exchange_gain,
        supplies_national_pension_insurance_premium: supplies_national_pension_insurance_premium,
        national_health_insurance: national_health_insurance,
        dc: dc,
        small_business_mutual_aid: small_business_mutual_aid,
        first_estimated_income_tax_prepayment: first_estimated_income_tax_prepayment,
        second_estimated_income_tax_prepayment: second_estimated_income_tax_prepayment,
        miscellaneous_income: miscellaneous_income,
        sales: sales,
        total: total
      }
    end
  end
end
