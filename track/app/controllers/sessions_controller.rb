class SessionsController < ApplicationViewController
  before_action :verify, only: [ :logout ]

  skip_before_action :verify_authenticity_token, only: [ :logout ]

  def new
    current_session
    redirect_to foreign_exchange_gain_dollar_yen_transactions_path if @session.present?
  end

  def logout
    # Current.session.destroy
    cookies.delete(:session_id)
    # TODO ここで不要な過去のsessionを削除する(最高ログは10まで)
    redirect_to sessions_signout_path
  end
end
