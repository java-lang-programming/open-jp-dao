class DollarYen < ApplicationRecord
  def formatted_date(format: "%Y/%m/%d")
    date.strftime(format)
  end

  def formatted_dollar_yen_nakane
    BigDecimal(dollar_yen_nakane).truncate(2).to_f
  end
end
