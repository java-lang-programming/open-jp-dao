# 　将来的にはmodelかな
module Requests
  class DollarYensTransaction
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :transaction_type_kind, :withdrawal_quantity, :exchange_en

    # validate :validate_invalid_withdrawal_quantity

    validates :withdrawal_quantity, presence: true, if: :withdrawal?
    validates :exchange_en, presence: true, numericality: { only_integer: true }, if: :withdrawal?

    def withdrawal?
      TransactionType.kinds[:withdrawal] === transaction_type_kind
    end


    def validate_withdrawal_quantity
      if withdrawal_quantity.present?
        begin
          bd = BigDecimal(withdrawal_quantity)
          # 　小数点部分
          fractional_part = bd.frac.to_s.sub("0.", "") # "0."を取り除く
          if fractional_part.length > 2
            errors.add(:withdrawal_quantity, "withdrawal_quantityの値が不正です。小数点2桁までで入力してください")
          end
        rescue => e
          errors.add(:withdrawal_quantity, "withdrawal_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください")
        end
      end
    end

    def error(request:, transaction_type_kind:)
      error = {}
      unless request[:date].present?
        error = { date: "日付は必須入力です" }
      end

      if TransactionType.kinds[:deposit] === transaction_type_kind
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

      elsif TransactionType.kinds[:withdrawal] === transaction_type_kind

        unless valid?
          errors.full_messages.each do |e|
            if e == "Withdrawal quantity can't be blank"
              error[:withdrawal_quantity] = "withdrawal_quantityは必須入力です"
            elsif e == "Exchange en can't be blank"
              error[:exchange_en] = "exchange_enは必須入力です"
            elsif e == "Exchange en must be an integer"
              error[:exchange_en] = "exchange_enの値が不正です。数値を入力してください" unless error.key?(:exchange_en)
            elsif e == "Exchange en is not a number"
              error[:exchange_en] = "exchange_enの値が不正です。数値を入力してください" unless error.key?(:exchange_en)
            end
          end
        end

        if withdrawal_quantity.present?
          begin
            bd = BigDecimal(withdrawal_quantity)
            # 　小数点部分
            fractional_part = bd.frac.to_s.sub("0.", "") # "0."を取り除く
            if fractional_part.length > 2
              error[:withdrawal_quantity] = "withdrawal_quantityの値が不正です。小数点2桁までで入力してください"
            end
          rescue => e
            error[:withdrawal_quantity] = "withdrawal_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください"
          end
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
