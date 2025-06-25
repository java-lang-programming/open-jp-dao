require 'rails_helper'

RSpec.describe "Ledgers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/ledger/index"
      expect(response).to have_http_status(:success)
    end
  end
end
