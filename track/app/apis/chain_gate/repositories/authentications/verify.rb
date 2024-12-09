module ChainGate
  module Repositories
    module Authentications
      class Verify < ChainGate::Base
        PATH = ChainGate::Url::VERIFY_POST

        def initialize(params:)
          @params = params
        end

        def path
          PATH
        end

        # TODO faradayを使ってretryも加味する
        def fetch
          response = post(@params, path)
          case response
          when Net::HTTPCreated then
            ChainGate::Responses::Authentications::Verify.new(
              status: ChainGate::Responses::Base::HTTP_CREATED, response: response
            )
          when Net::HTTPBadRequest then
            ChainGate::Responses::Authentications::Verify.new(
              status: ChainGate::Responses::Base::HTTP_BAD_REQUEST, response: response
            )
          when Net::HTTPInternalServerError
            ChainGate::Responses::Authentications::Verify.new(
              status: ChainGate::Responses::Base::HTTP_INTERNAL_SERVER_ERROR, response: response
            )
          else
            ChainGate::Responses::Authentications::Verify.new(
              status: ChainGate::Responses::Base::UNEXPECTED_ERROR, response: nil
            )
          end
        end
      end
    end
  end
end
