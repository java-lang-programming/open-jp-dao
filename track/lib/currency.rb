class Currency
  extend ActionView::Helpers::NumberHelper
  class << self
    # 円の端数計算
    # 端数の処理についてはすべて切り捨て
    # 100ドルを140.123のレートで両替した場合 → 14,012円の受取です。
    # 円換算結果が11,577.16523 → 11,577円の受取です。
    def en_with_unit(value: nil)
      return number_to_currency(value, unit: "¥", separator: ".", delimiter: ",", precision: 0) if value.present?
      nil
    end
  end
end
