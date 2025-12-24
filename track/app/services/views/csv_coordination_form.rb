module Views
  class CsvCoordinationForm
    include Views::Status

    attr_accessor :form_status

    def initialize
      @form_status = {
        name: { status: STATUS_READY, msg: nil }
      }
    end

    def execute(external_service_transaction_type:)
      if external_service_transaction_type.errors[:name].present?
        @form_status[:name] = {
          status: STATUS_FAILURE,
          msg: error_msg(external_service_transaction_type: external_service_transaction_type, attribute: :name)
        }
      else
        @form_status[:name] = { status: STATUS_COMPLETE, msg: nil }
      end
    end

    private

      def error_msg(external_service_transaction_type:, attribute:)
        ExternalServiceTransactionType.human_attribute_name(attribute) + external_service_transaction_type.errors[attribute][0]
      end
  end
end
