module ChainGate
  module Responses
    module Sessions
      class Verify
        include ChainGate::Responses::Base

        attr_accessor :status, :error_symbol, :success_symbol

        def initialize(status:, response:)
          self.status = status
          case status
          when HTTP_BAD_REQUEST, HTTP_FORBIDDEN
            self.error_symbol = to_sym_json(body: response.body)
          when HTTP_CREATED
            self.success_symbol = {}
          else
            self.error_symbol = ERROR_HASH
          end
        end

        def status_code
          status
        end
      end
    end
  end
end
