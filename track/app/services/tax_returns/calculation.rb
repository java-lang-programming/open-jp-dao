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

      # これらの値はとりあえずhashかな。
      # 通信費
      communication_expense = base.where(ledger_item_id: 1).sum(:recorded_amount)
      # puts "通信費"
      # puts communication_expense
      # 水道光熱費
      utility_costs =  base.where(ledger_item_id: 2).sum(:recorded_amount)
      # puts "水道光熱費"
      # puts utility_costs
      # 消耗品費
      supplies_expense = base.where(ledger_item_id: 3).sum(:recorded_amount)
      # puts "消耗品費"
      # puts supplies_expense
      {
        communication_expense: communication_expense,
        utility_costs: utility_costs,
        supplies_expense: supplies_expense
      }
    end
  end
end
