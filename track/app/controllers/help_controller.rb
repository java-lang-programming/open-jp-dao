class HelpController < ApplicationViewController
  def index
    header_session
  end

  private

  def header_session
    @user = user
    @notification = notification
  end
end
