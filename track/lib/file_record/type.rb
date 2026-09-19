module FileRecord
  module Type
    TYPE_MONEY_EN = "money_en"
    # お金の円をintegerにする
    def money_en_to_integer(value:)
      normalized = value.to_s
                        .delete(",")
                        .gsub(/\A'|'?\Z/, "")

      Integer(normalized)
    end

    def money_to_numeric(value:)
      # 通貨記号（$, ¥, €, £）やカンマ、シングルクォートを除去
      normalized = value.to_s
                        .gsub(/[$,¥€£']/, "")
                        .strip

      # ドットが含まれていれば Float、なければ Integer で変換
      normalized.include?(".") ? Float(normalized) : Integer(normalized)
    end
  end
end
