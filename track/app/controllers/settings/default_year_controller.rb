class Settings::DefaultYearController < ApplicationViewController
  include Nav
  before_action :verify

  def index
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SettingsController::ITEMS[1]
    @setting = @session.address.setting
  end

  def update
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SettingsController::ITEMS[1]

    setting = @session.address.setting

    if setting.update(setting_params)
      redirect_to settings_default_year_path, flash: { toast_notice: "デフォルト年度を更新しました" }
    else
      # 失敗時にエラー内容をログに記録
      Rails.logger.error "Setting update failed for Address ID: #{@session.address.id}. Errors: #{setting.errors.full_messages.join(', ')}"
      redirect_to settings_default_year_path, flash: { toast_alert: "デフォルト年度の更新に失敗しました" }
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:default_year)
  end
end
