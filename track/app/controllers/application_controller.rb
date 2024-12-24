class ApplicationController < ActionController::API
  include ActionController::Cookies

  def find_session_by_cookie
   Session.find_by(id: cookies.signed[:session_id])
  end
  # include Authentication
  def verify_v2
    session = find_session_by_cookie
    unless session.present?
      # TOD railsでログを出す
      render json: { errors: [ { msg: "権限がありません" } ] }, status: :unauthorized
      return
    end

    chain_id = session.chain_id
    message = session.message
    signature = session.signature
    domain = session.domain
    verify_params = session.make_verify_params(nonce: cookies.signed[:nonce])

    response = nil
    begin
      response = ChainGate::Repositories::Authentications::Verify.new(params: verify_params).fetch
    rescue => e
      logger.error(e.message)
      render json: { errors: [ { msg: e } ] }, status: :unauthorized
      return
    end

    unless 201 == response.status_code
      render json: { errors: [ { msg: "認証に失敗しました" } ] }, status: :unauthorized
      nil
    end
  end
end
