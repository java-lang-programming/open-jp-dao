require 'rails_helper'

RSpec.describe Settings::AccountsController, type: :request do
  let(:addresses_eth) { create(:addresses_eth) }

  describe "GET /show" do
    context 'ログイン情報なし' do
      it "returns http success" do
        get settings_accounts_path
        expect(response.body).to match('ログイン情報がありません。')
      end
    end

    context 'ログイン情報あり' do
      before do
        sign_in_as(address_record: addresses_eth)
      end

      it "returns http ok" do
        get settings_accounts_path
        expect(response).to have_http_status(:ok)
        body = response.body
        expect(body).to match('アカウント情報')
        expect(body).to match('アカウント削除')
      end
    end
  end
end
