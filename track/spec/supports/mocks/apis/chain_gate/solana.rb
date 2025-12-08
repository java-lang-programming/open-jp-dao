module Mocks
  module Apis
    module ChainGate
      module Solana
        def mock_apis_solana_verify(status_code:, request_body:, body:)
          stub_request(:post, %r{/api/solana/verify})
            .with(
              body: request_body
            )
            .to_return(
              status: status_code,
              body: body.to_json
            )
        end
      end
    end
  end
end
