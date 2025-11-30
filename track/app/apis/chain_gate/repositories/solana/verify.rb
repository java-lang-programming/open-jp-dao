module ChainGate
  module Repositories
    module Solana
      class Verify < ChainGate::Base
        PATH = ChainGate::Url::SOLANA_VERIFY_POST

        def initialize(params:)
          @params = params
        end

        def path
          PATH
        end

        def fetch
          response = post(@params, path)
          case response
          when Net::HTTPOK then
            ChainGate::Responses::Solana::Verify.new(
              status: ChainGate::Responses::Base::HTTP_OK, response: response
            )
          when Net::HTTPBadRequest then
            ChainGate::Responses::Solana::Verify.new(
              status: ChainGate::Responses::Base::HTTP_BAD_REQUEST, response: response
            )
          else
            ChainGate::Responses::Solana::Verify.new(
              status: ChainGate::Responses::Base::HTTP_INTERNAL_SERVER_ERROR, response: nil
            )
          end
        end
      end
    end
  end
end
