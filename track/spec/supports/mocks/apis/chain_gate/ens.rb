module Mocks
  module Apis
    module ChainGate
      module Ens
        def mock_apis_ens(status:, body: {}, headers: { "Cache-Control" => "public, max-age=86400" })
          stub_request(:get, %r{/api/ethereum/\d+/address/[a-zA-Z0-9]+/ens}).to_return(
            status: status,
            body: body.present? ? body.to_json : nil,
            headers: headers
          )
        end
      end
    end
  end
end
