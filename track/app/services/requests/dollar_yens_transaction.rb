# 　将来的にはmodelかな
module Requests
  class DollarYensTransaction
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :transaction_type, :date, :deposit_quantity, :deposit_rate, :withdrawal_quantity, :exchange_en

    # validate :validate_invalid_withdrawal_quantity

    validates :transaction_type, presence: true
    validates :date, presence: true
    validates :deposit_quantity, presence: true, if: :deposit?
    validates :deposit_rate, presence: true, if: :deposit?
    validates :withdrawal_quantity, presence: true, if: :withdrawal?
    validates :exchange_en, presence: true, numericality: { only_integer: true }, if: :withdrawal?

    def deposit?
      TransactionType.kinds.key(1) === transaction_type.kind
    end

    def withdrawal?
      TransactionType.kinds.key(2) === transaction_type.kind
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

    def get_errors
      error = {}

      if deposit?

        unless valid?
          errors.full_messages.each do |e|
            if e == "Date can't be blank"
              error[:date] = "日付は必須入力です"
            elsif e == "Deposit quantity can't be blank"
              error[:deposit_quantity] = "deposit_quantityは必須入力です"
            elsif e == "Deposit rate can't be blank"
              error[:deposit_rate] = "deposit_rateは必須入力です"
            end
          end
        end


        if deposit_quantity.present?
          begin
            bd = BigDecimal(deposit_quantity)
            # 　小数点部分
            fractional_part = bd.frac.to_s.sub("0.", "") # "0."を取り除く
            if fractional_part.length > 2
              error[:deposit_quantity] = "deposit_quantityの値が不正です。小数点2桁までで入力してください"
            end
          rescue => e
            error[:deposit_quantity] = "deposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください"
          end
        end

        if deposit_rate.present?
          begin
            bd = BigDecimal(deposit_rate)
            # 　小数点部分
            fractional_part = bd.frac.to_s.sub("0.", "") # "0."を取り除く
            if fractional_part.length > 2
              error[:deposit_rate] = "deposit_rateの値が不正です。小数点2桁までで入力してください"
            end
          rescue => e
            error[:deposit_rate] = "deposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください"
          end
        end

      elsif withdrawal?

        unless valid?
          errors.full_messages.each do |e|
            if e == "Date can't be blank"
              error[:date] = "日付は必須入力です"
            elsif e == "Withdrawal quantity can't be blank"
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

    def to_dollar_yen_transaction(errors:, address:)
      dollar_yen_transaction = DollarYenTransaction.new
      dollar_yen_transaction.address = address
      dollar_yen_transaction.transaction_type = transaction_type
      unless errors.key?(:date)
        splited_date = date.split("-")
        dollar_yen_transaction.date = Date.new(splited_date[0].to_i, splited_date[1].to_i, splited_date[2].to_i)
      end

      if deposit?
        unless errors.key?(:deposit_quantity)
          dollar_yen_transaction.deposit_quantity = BigDecimal(deposit_quantity)
        end

        unless errors.key?(:deposit_rate)
          dollar_yen_transaction.deposit_rate = BigDecimal(deposit_rate)
        end
      elsif withdrawal?
        dollar_yen_transaction.withdrawal_quantity = BigDecimal(withdrawal_quantity)
        dollar_yen_transaction.exchange_en = BigDecimal(exchange_en)
      end
      dollar_yen_transaction
    end

    def html_errors(errors:)
      html_errors = {}
      if errors.present?
        html_errors[:deposit_quantity_class] = "form_input"
        if errors[:deposit_quantity].present?
          html_errors[:deposit_quantity_msg] = errors[:deposit_quantity]
        else
          html_errors[:deposit_quantity_msg] = ""
        end
      else
        html_errors[:deposit_quantity_class] = "form_input form_input_ng"
        html_errors[:deposit_quantity_msg] = ""
      end
      html_errors
    end
  end
end
