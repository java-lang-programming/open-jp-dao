require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /logout" do
    let(:addresses_eth) { create(:addresses_eth) }

    context 'success' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        mock_apis_ens(
          status: 200,
          body: { ens_name: "test.eth" }
        )
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      it "should get view message." do
        post sessions_logout_path
        expect(response.status).to eq(302)
      end
    end
  end
end
