module ChainGate
  module Responses
    module Sessions
      class Ens
        include ChainGate::Responses::Base

        attr_accessor :status, :error_symbol, :success_symbol

        def initialize(status:, response:)
          self.status = status
          case status
          when HTTP_BAD_REQUEST, HTTP_FORBIDDEN
            self.error_symbol = to_sym_json(body: response.body)
          when HTTP_OK
            self.success_symbol = to_sym_json(body: response.body)
          else
            self.error_symbol = ERROR_HASH
          end
        end

        def result
          return self.status, self.success_symbol if self.status == HTTP_OK
          return self.status, self.error_symbol
        end
      end
    end
  end
end
