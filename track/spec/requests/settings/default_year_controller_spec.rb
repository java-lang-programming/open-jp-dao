require 'rails_helper'

RSpec.describe Settings::DefaultYearController, type: :request do
  let(:addresses_eth) { create(:addresses_eth, :with_setting, ens_name: 'test.eth') }

  describe "GET /index" do
    context 'ログイン情報なし' do
      it "returns http success" do
        get settings_default_year_path
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
        expect(body).to match('デフォルト年度')
        expect(body).to match(addresses_eth.setting.default_year.to_s)
      end
    end
  end

  describe "GET /update" do
    context 'ログイン情報なし' do
      it "returns http success" do
        patch settings_default_year_path
        expect(response.body).to match('ログイン情報がありません。')
      end
    end

    context 'ログイン情報あり' do
      before do
        sign_in_as(address_record: addresses_eth)
      end

      context 'when default_year is valid' do
        it "should be redirected." do
          patch settings_default_year_path, params: { setting: { default_year: 2025 } }
          expect(response).to have_http_status(:found) # 302
          expect(flash[:toast_notice]).to eq "デフォルト年度を更新しました"

          # リダイレクトを追いかける
          follow_redirect!

          expect(response.body).to match('デフォルト年度')
          expect(response.body).to match('2025')
        end
      end

      context 'when default_year is invalid' do
        it "should be redirected." do
          patch settings_default_year_path, params: { setting: { default_year: 'aaaaa' } }
          expect(response).to have_http_status(:found) # 302
          expect(flash[:toast_alert]).to eq "デフォルト年度の更新に失敗しました"

          # リダイレクトを追いかける
          follow_redirect!

          expect(response.body).to match('デフォルト年度')
          # 更新されていないこと
          expect(response.body).to match('2026')
        end

        it "ログにエラーが記録されること" do
          # Rails.logger.error が呼ばれるか検証する高度なテスト例
          expect(Rails.logger).to receive(:error).with(/Setting update failed/)
          patch settings_default_year_path, params: { setting: { default_year: 'aaaa' } }
        end
      end
    end
  end
end
