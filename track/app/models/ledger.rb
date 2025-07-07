
class Ledger < ApplicationRecord
  include ActionView::Helpers::NumberHelper

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

  def face_value_screen
    Currency.en_with_unit(value: face_value)
  end

  def proportion_amount_screen
    return nil unless proportion_amount.present?
    Currency.en_with_unit(value: proportion_amount)
  end

  def proportion_rate_screen
    return nil unless proportion_rate.present?
    proportion_rate.to_f
  end

  def recorded_amount_screen
    return nil unless recorded_amount.present?
    Currency.en_with_unit(value: recorded_amount)
  end
end
