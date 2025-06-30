
class Ledger < ApplicationRecord
  belongs_to :ledger_item
  belongs_to :address

  # 　計上額を計算する
  def calculate_recorded_amount
    bd_face_value = BigDecimal(face_value)
    if !proportion_rate.nil? && !proportion_amount.nil?
      value = bd_face_value - proportion_amount
      result = value * proportion_rate
      return to_en(value: result)
    end

    if !proportion_rate.nil? && proportion_amount.nil?
      result = bd_face_value * proportion_rate
      return to_en(value: result)
    end

    to_en(value: bd_face_value)
  end

  def to_en(value:)
    BigDecimal(value).floor(0).to_i
  end
end
