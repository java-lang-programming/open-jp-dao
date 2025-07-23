module Views
  class DollarYenTransactionForm
    include Views::Status

    attr_accessor :form_status

    def initialize(transaction_type:)
      @form_status = {
        deposit?: transaction_type.deposit? ? true : false,
        withdrawal?: transaction_type.withdrawal? ? true : false,
        date: { status: STATUS_READY, msg: nil },
        deposit_quantity: { status: STATUS_READY, msg: nil },
        deposit_rate: { status: STATUS_READY, msg: nil },
        withdrawal_quantity: { status: STATUS_READY, msg: nil },
        exchange_en: { status: STATUS_READY, msg: nil }
      }
    end

    def execute(dollar_yen_transaction:)
      @form_status[:deposit?] = dollar_yen_transaction.deposit?
      @form_status[:withdrawal?] = dollar_yen_transaction.withdrawal?

      if dollar_yen_transaction.errors[:date].present?
        @form_status[:date] = { status: STATUS_FAILURE, msg: error_msg(dollar_yen_transaction: dollar_yen_transaction, attribute: :date) }
      else
        @form_status[:date] = { status: STATUS_COMPLETE, msg: nil }
      end

      if dollar_yen_transaction.errors[:deposit_quantity].present?
        @form_status[:deposit_quantity] = { status: STATUS_FAILURE, msg: error_msg(dollar_yen_transaction: dollar_yen_transaction, attribute: :deposit_quantity) }
      else
        @form_status[:deposit_quantity] = { status: STATUS_COMPLETE, msg: nil }
      end

      if dollar_yen_transaction.errors[:deposit_rate].present?
        @form_status[:deposit_rate] = { status: STATUS_FAILURE, msg: error_msg(dollar_yen_transaction: dollar_yen_transaction, attribute: :deposit_rate) }
      else
        @form_status[:deposit_rate] = { status: STATUS_COMPLETE, msg: nil }
      end

      if dollar_yen_transaction.errors[:withdrawal_quantity].present?
        @form_status[:withdrawal_quantity] = { status: STATUS_FAILURE, msg: error_msg(dollar_yen_transaction: dollar_yen_transaction, attribute: :withdrawal_quantity) }
      else
        @form_status[:withdrawal_quantity] = { status: STATUS_COMPLETE, msg: nil }
      end

      if dollar_yen_transaction.errors[:exchange_en].present?
        @form_status[:exchange_en] = { status: STATUS_FAILURE, msg: error_msg(dollar_yen_transaction: dollar_yen_transaction, attribute: :exchange_en) }
      else
        @form_status[:exchange_en] = { status: STATUS_COMPLETE, msg: nil }
      end
    end

    # def deposit_block
    #   return "block;" if deposit?
    #   "none;"
    # end

    # def withdrawal_block
    #   return "block;" if withdrawal?
    #   "none;"
    # end

    private

      def error_msg(dollar_yen_transaction:, attribute:)
        DollarYenTransaction.human_attribute_name(attribute) + dollar_yen_transaction.errors[attribute][0]
      end
  end
end
