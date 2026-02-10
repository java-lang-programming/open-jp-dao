require 'rails_helper'

RSpec.describe TaxReturnsController, type: :request do
  let(:addresses_eth) { create(:addresses_eth) }

  describe "GET /index" do
    context 'without session' do
      it "returns not_found_session.html.erb when session is not found." do
        get tax_returns_path
        expect(response.body).to match('ログイン情報がありません。')
      end
    end

    context 'when session is find' do
      let(:addresses_eth) { create(:addresses_eth, :with_setting) }

      before do
        sign_in_as(address_record: addresses_eth)
      end

      it "returns not_found_session.html.erb when session is not found." do
        get tax_returns_path
        expect(response.body).to include '2026年仕訳結果'
      end
    end
  end
end
