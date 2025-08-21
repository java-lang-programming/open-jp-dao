class SettingsController < ApplicationViewController
  include Nav
  before_action :verify, only: [ :index ]

  def index
    @navs = settings_navs(selected: ACCOUNT)
    @user = user
  end
end
