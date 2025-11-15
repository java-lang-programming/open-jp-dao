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
      # 小規模共済
      small_business_mutual_aid = base.where(ledger_item_id: LedgerItem::ID_SMALL_BUSINESS_MUTUAL_AID).sum(:recorded_amount)
      {
        communication_expense: communication_expense,
        utility_costs: utility_costs,
        supplies_expense: supplies_expense,
        foreign_exchange_gain: foreign_exchange_gain,
        supplies_national_pension_insurance_premium: supplies_national_pension_insurance_premium,
        national_health_insurance: national_health_insurance,
        small_business_mutual_aid: small_business_mutual_aid
      }
    end
  end
end
