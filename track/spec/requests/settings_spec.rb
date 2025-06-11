require 'rails_helper'

RSpec.describe "Settings", type: :request do
  describe "GET /index" do
    let(:addresses_eth) { create(:addresses_eth) }

    context 'success' do
      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      it "should get view message." do
        get settings_path
        expect(response.status).to eq(200)
      end
    end
  end
end
