class Settings::AccountController < ApplicationViewController
  include Nav
  before_action :verify

  def info
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SettingsController::ITEMS[0]
    @address = @session.address
    # ログインchianもわからないとあかんな
    @info = {
      ens_app_link: @address.ens_app_link(chain_id: @session.chain_id),
      etherscan_link: @address.etherscan_link(chain_id: @session.chain_id)
    }
  end

  def delete
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SettingsController::ITEMS[0]
    @address = @session.address
  end
end
