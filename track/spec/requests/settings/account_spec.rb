require 'rails_helper'

RSpec.describe Settings::AccountController, type: :request do
  let(:addresses_eth) { create(:addresses_eth, ens_name: 'test.eth') }

  describe "GET /info" do
    context 'ログイン情報なし' do
      it "returns http success" do
        get settings_account_info_path
        expect(response.body).to match('ログイン情報がありません。')
      end
    end

    context 'ログイン情報あり' do
      before do
        sign_in_as(address_record: addresses_eth)
      end

      it "returns http ok" do
        get settings_account_info_path
        expect(response).to have_http_status(:ok)
        body = response.body
        expect(body).to match('アドレス')
        expect(body).to match(addresses_eth.address)
        expect(body).to match('ENS')
        expect(body).to match(addresses_eth.ens_name)
      end
    end
  end

  describe "GET /delete" do
    context 'ログイン情報なし' do
      it "returns http success" do
        get settings_account_delete_path
        expect(response.body).to match('ログイン情報がありません。')
      end
    end

    context 'ログイン情報あり' do
      before do
        sign_in_as(address_record: addresses_eth)
      end

      it "returns http ok" do
        get settings_account_delete_path
        expect(response).to have_http_status(:ok)
        body = response.body
        expect(body).to match(addresses_eth.address)
        expect(body).to match(addresses_eth.ens_name)
        expect(body).to match('アカウント削除')
      end
    end
  end
end
