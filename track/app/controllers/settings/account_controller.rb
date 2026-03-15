class Settings::AccountController < ApplicationViewController
  include Nav
  before_action :verify

  def info
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SETTINGS_LEFT_ITEMS[0]
    @address = @session.address
    @setting = @address.setting
    # ログインchianもわからないとあかんな
    @info = {
      ens_app_link: @address.ens_app_link(chain_id: @session.chain_id),
      etherscan_link: @address.etherscan_link(chain_id: @session.chain_id)
    }
  end

  def delete
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SETTINGS_LEFT_ITEMS[0]
    @address = @session.address
  end

  def update_locale
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SETTINGS_LEFT_ITEMS[0]

    setting = @session.address.setting

    # ここからrescueがいいな。あとで
    if setting.update(setting_params)
      redirect_to settings_account_info_path, flash: { toast_notice: "言語を更新しました" }
    else
      # 失敗時にエラー内容をログに記録
      Rails.logger.error "Setting update failed for Address ID: #{@session.address.id}. Errors: #{setting.errors.full_messages.join(', ')}"
      redirect_to settings_account_info_path, flash: { toast_alert: "言語の更新に失敗しました" }
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:language)
  end
end
