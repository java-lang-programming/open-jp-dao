class Settings::AccountsController < ApplicationViewController
  include Nav
  before_action :verify

  def index
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
    @selected_item = SETTINGS_LEFT_ITEMS[0]
  end
end
