module Views
  class LedgerForm
    attr_accessor :form

    def initialize
      @form = {
        date: { status: "ready", msg: nil },
        name: { status: "ready", msg: nil },
        face_value: { status: "ready", msg: nil },
        proportion_rate: { status: "ready", msg: nil },
        proportion_amount: { status: "ready", msg: nil }
      }
    end

    def execute(ledger:)
      if ledger.errors[:date].present?
        @form[:date] = { status: "failure", msg: error_msg(ledger: ledger, attribute: :date) }
      else
        @form[:date] = { status: "complete", msg: nil }
      end

      if ledger.errors[:name].present?
        @form[:name] = { status: "failure", msg: error_msg(ledger: ledger, attribute: :name) }
      else
        @form[:name] = { status: "complete", msg: nil }
      end

      if ledger.errors[:face_value].present?
        @form[:face_value] = { status: "failure", msg: error_msg(ledger: ledger, attribute: :face_value) }
      else
        @form[:face_value] = { status: "complete", msg: nil }
      end

      if ledger.errors[:proportion_rate].present?
        @form[:proportion_rate] = { status: "failure", msg: error_msg(ledger: ledger, attribute: :proportion_rate) }
      else
        @form[:proportion_rate] = { status: "complete", msg: nil }
      end

      if ledger.errors[:proportion_amount].present?
        @form[:proportion_amount] = { status: "failure", msg: error_msg(ledger: ledger, attribute: :proportion_amount) }
      else
        @form[:proportion_amount] = { status: "complete", msg: nil }
      end
    end

    private

      def error_msg(ledger:, attribute:)
        Ledger.human_attribute_name(attribute) + ledger.errors[attribute][0]
      end
  end
end
