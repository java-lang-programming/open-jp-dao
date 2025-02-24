class ApplicationViewController < ActionController::Base
  include ActionController::Cookies

  # セッションデータがない
  class NotFoundSession < StandardError; end
  # ChainGateへの接続ができない
  class ChainGateConnectionRefused < StandardError; end
  # ChainGateのverifyが失敗
  class ChainGateVerifyFailure < StandardError; end

  rescue_from NotFoundSession, with: :redirect_not_found_session_page
  rescue_from ChainGateConnectionRefused, with: :redirect_chain_gate_connection_refused_page
  rescue_from ChainGateVerifyFailure, with: :redirect_chain_gate_verify_failure_page

  def redirect_not_found_session_page
    render template: "errors/not_found_session"
  end

  def redirect_chain_gate_connection_refused_page
    # TODO このエラーは致命的なのでシステム管理者に通知する(slackかなあ)
    render template: "errors/chain_gate_connection_refused"
  end

  def redirect_chain_gate_verify_failure_page
    render template: "errors/chain_gate_verify_failure"
  end

  allow_browser versions: :modern

  layout "application"

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id])
  end

  def verify
    @session ||= find_session_by_cookie
    raise NotFoundSession unless @session.present?

    chain_id = @session.chain_id
    message = @session.message
    signature = @session.signature
    domain = @session.domain
    verify_params = @session.make_verify_params(nonce: cookies.signed[:nonce])

    response = nil
    begin
      response = ChainGate::Repositories::Authentications::Verify.new(params: verify_params).fetch
    rescue => e
      logger.error(e.message)
      # FIX ここのテストが通せない
      raise ChainGateConnectionRefused
    end

    # 認証失敗の場合は例外
    raise ChainGateVerifyFailure unless 201 == response.status_code
  end

  # headerのユーザー情報取得
  def user
    @session ||= find_session_by_cookie
    return { errors: [ { msg: "ログイン情報がありません" } ] } unless @session.present?
    { address: @session.address.address, network: @session.network, last_login: @session.last_login }
  end
end
