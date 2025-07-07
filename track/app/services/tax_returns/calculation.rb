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
      # 　これは共通化したいね
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
      {
        communication_expense: communication_expense,
        utility_costs: utility_costs,
        supplies_expense: supplies_expense,
        foreign_exchange_gain: foreign_exchange_gain
      }
    end

    def execute_on_screen
      result = execute
      {
        communication_expense: Currency.en_with_unit(value: result[:communication_expense]),
        utility_costs: Currency.en_with_unit(value: result[:utility_costs]),
        supplies_expense: Currency.en_with_unit(value: result[:supplies_expense]),
        foreign_exchange_gain: Currency.en_with_unit(value: result[:foreign_exchange_gain])
      }
    end
  end
end
