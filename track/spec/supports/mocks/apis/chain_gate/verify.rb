module Mocks
  module Apis
    module ChainGate
      module Verify
        # /apis/verify
        def mock_apis_verify(body:)
          stub_request(:post, /api\/verify/).to_return(
            status: 201,
            body: body.to_json,
            headers: {
              "Cache-Control" => "public, max-age=86400"
            }
          )
        end
      end
    end
  end
end
