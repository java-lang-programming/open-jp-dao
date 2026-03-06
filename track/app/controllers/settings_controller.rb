class SettingsController < ApplicationViewController
  include Nav
  before_action :verify, only: [ :index ]

  ITEMS = [ "account", "default_year" ]

  def index
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SettingsController::ITEMS[0]
  end

  # setting::accounts#infoに移植
  # account_info_settings
  def account_info
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SettingsController::ITEMS[0]
    @address = @session.address
  end

  def default_year
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SettingsController::ITEMS[1]
    @setting = @session.address.setting
  end

  def years
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SettingsController::ITEMS[1]
    @setting = @session.address.setting
  end
end
