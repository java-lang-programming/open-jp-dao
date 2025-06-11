class SettingsController < ApplicationViewController
  before_action :verify, only: [ :index ]

  def index
    @user = user
  end
end
