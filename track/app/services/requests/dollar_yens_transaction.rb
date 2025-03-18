
module Requests
  class DollarYensTransaction
    def error(request:)
      error = {}
      unless request[:date].present?
        error = { date: "日付は必須入力です" }
      end

      # TODO typeで入力項目を切り替えsる

      unless request[:deposit_quantity].present?
        error[:deposit_quantity] = "deposit_quantityは必須入力です"
      else
        begin
          bd = BigDecimal(request[:deposit_quantity])
          # 　小数点部分
          fractional_part = bd.frac.to_s.sub("0.", "") # "0."を取り除く
          if fractional_part.length > 2
            error = { deposit_quantity: "deposit_quantityの値が不正です。小数点2桁までで入力してください" }
          end
        rescue => e
          error = { deposit_quantity: "deposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" }
        end
      end

      unless request[:deposit_rate].present?
        error[:deposit_rate] = "deposit_rateは必須入力です"
      else
        begin
          bd = BigDecimal(request[:deposit_rate])
          # 　小数点部分
          fractional_part = bd.frac.to_s.sub("0.", "") # "0."を取り除く
          if fractional_part.length > 2
            error = { deposit_rate: "deposit_rateの値が不正です。小数点2桁までで入力してください" }
          end
        rescue => e
          error = { deposit_rate: "deposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" }
        end
      end
      error
    end

    def to_date(request:)
      splited_date = request[:date].split("-")
      Date.new(splited_date[0].to_i, splited_date[1].to_i, splited_date[2].to_i)
    end
  end
end
