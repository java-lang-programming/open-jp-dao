module ChainGate
  module Responses
    module Solana
      class Verify
        include ChainGate::Responses::Base

        attr_accessor :status, :error_symbol, :success_symbol

        def initialize(status:, response:)
          self.status = status
          case status
          when HTTP_UNAUTHORIZED, HTTP_UNPROCESSABLE_CONTENT
            self.error_symbol = to_sym_json(body: response.body)
          when HTTP_OK
            self.success_symbol = to_sym_json(body: response.body)
          else
            self.error_symbol = ERROR_HASH
          end
        end

        def status_code
          status
        end

        def result
          return self.success_symbol if self.status == HTTP_OK
          self.error_symbol
        end
      end
    end
  end
end
