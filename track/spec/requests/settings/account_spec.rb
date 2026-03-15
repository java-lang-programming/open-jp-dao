require 'rails_helper'

RSpec.describe Settings::AccountController, type: :request do
  let(:addresses_eth) { create(:addresses_eth, :with_setting, ens_name: 'test.eth') }

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

  describe "patch /update_locale" do
    context 'ログイン情報なし' do
      it "returns http success" do
        patch settings_account_locale_path
        expect(response.body).to match('ログイン情報がありません。')
      end
    end

    context 'ログイン情報あり' do
      before do
        sign_in_as(address_record: addresses_eth)
      end

      context 'when default_year is valid' do
        it "should be redirected." do
          patch settings_account_locale_path, params: { setting: { language: 'en' } }
          expect(response).to have_http_status(:found) # 302
          expect(flash[:toast_notice]).to eq "言語を更新しました"

          # リダイレクトを追いかける
          follow_redirect!

          expect(response.body).to match('default year')
          expect(response.body).to match('2025')
        end
      end

      context 'when default_year is invalid' do
        it "should be redirected." do
          patch settings_account_locale_path, params: { setting: { language: 'aaaa' } }
          expect(response).to have_http_status(:found) # 302
          expect(flash[:toast_alert]).to eq "言語の更新に失敗しました"

          # リダイレクトを追いかける
          follow_redirect!

          expect(response.body).to match('デフォルト年度')
          # 更新されていないこと
          expect(response.body).to match('2026')
        end

        it "ログにエラーが記録されること" do
          # Rails.logger.error が呼ばれるか検証する高度なテスト例
          expect(Rails.logger).to receive(:error).with(/Errors: Language はja, enの中から選択してください/)
          patch settings_account_locale_path, params: { setting: { language: 'aaaa' } }
        end
      end
    end
  end
end
