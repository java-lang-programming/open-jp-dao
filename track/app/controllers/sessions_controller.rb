class SessionsController < ApplicationViewController
  before_action :verify, only: [ :logout ]

  skip_before_action :verify_authenticity_token, only: [ :logout ]

  def logout
    # Current.session.destroy
    cookies.delete(:session_id)
    # TODO ここで不要な過去のsessionを削除する(最高ログは10まで)
    redirect_to sessions_signout_path
  end

  def signout
  end
end
