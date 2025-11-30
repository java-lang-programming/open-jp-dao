require 'rails_helper'

RSpec.describe Apis::SolanaController, type: :request do
  describe "GET /signin" do
    let(:public_key) {
      '9tk1nAVyAfS4RDYxfHNYQRg1EU1EhMnDNgfSwB3c1sC9'
    }
    let(:signature) {
      '2b5EYicrBGXprZBpQq6HUNT7TPWHFWaSRqMfu3zUBgKneyPkGh8YsPaEDQDGb3Dyr185rdqbF3zLPUU7VzfNpN2v'
    }
    let(:message) {
      'Sign in with phantom to the WanWan.'
    }
    let(:kind) { 2 }

    it "returns http success" do
      post apis_solana_signin_path, params: {
        public_key: public_key,
        signature: signature,
        message: message,
        kind: kind
      }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
