class Unit
  # 米ドル
  EN_DOLLAR = "dollar"
  # 日本円
  JP_EN = "en"

  # 単位データがない
  class NotFoundUnit < StandardError; end

  class << self
    # valueにunitで指定した単位を追加する
    def add_unit(value:, unit: Unit::JP_EN)
      return "" unless value
      if unit == Unit::JP_EN
        "¥" + value.to_s
      elsif unit == Unit::EN_DOLLAR
        "$" + value.to_s
      else
        raise NotFoundUnit
      end
    end
  end
end
