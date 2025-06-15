module ChainGate
  module Repositories
    module Sessions
      class Ens < ChainGate::Base
        PATH = ChainGate::Url::ENS_GET

        def initialize(chain_id:, address:)
          @chain_id = chain_id
          @address = address
        end

        def path
          ChainGate::Url::ENS_GET.sub(/:chain_id/, @chain_id.to_s).sub(/:address/, @address)
        end

        # TODO faradayを使ってretryも加味する
        # あとはopen apiからrunnとコードを生成可能にしていく
        def fetch
          response = get(path: path, query: @params)
          case response
          when Net::HTTPOK then
            ChainGate::Responses::Sessions::Ens.new(
              status: ChainGate::Responses::Base::HTTP_OK, response: response
            )
          when Net::HTTPBadRequest then
            ChainGate::Responses::Sessions::Ens.new(
              status: ChainGate::Responses::Base::HTTP_BAD_REQUEST, response: response
            )
          when Net::HTTPForbidden
            ChainGate::Responses::Sessions::Ens.new(
              status: ChainGate::Responses::Base::HTTP_FORBIDDEN, response: response
            )
          else
            ChainGate::Responses::Sessions::Ens.new(
              status: ChainGate::Responses::Base::HTTP_INTERNAL_SERVER_ERROR, response: nil
            )
          end
        end
      end
    end
  end
end
