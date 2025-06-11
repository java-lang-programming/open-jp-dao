# noceとsesson_idの名称 _hoge_nonce
# 次 verifyのopena apiとエラーハンドリングとnonce実装
class Apis::SessionsController < ApplicationController
  include ActionController::Cookies
  # https://zenn.dev/makoto00000/articles/843b7f164b4ddd
  # https://office54.net/iot/programming/http-stateless-session セッションは的まえる
  def nonce
    nonce = Array.new(20) { [ *"a".."z", *"A".."Z" ].sample }.join
    cookies.signed.permanent[:nonce] = nonce
    render status: :ok, json: { nonce: nonce }
  end

  # 　一時しのぎで今は実装しておく
  # https://github.com/rails/rails/issues/53207
  # https://github.com/rails/rails/blob/91d456366638ac6c3f6dec38670c8ada5e7c69b1/actionpack/lib/action_dispatch/middleware/cookies.rb#L11
  def signin
    target_address = params[:address]
    unless target_address.present?
      render json: { errors: [ { msg: "addressは必須パラメーターです" } ] }, status: :bad_request
      return
    end

    kind = params[:kind]
    errors = Address.kind_errors(kind: kind)
    if errors.present?
      render json: { errors: errors.map { |e| { msg: e } } }, status: :bad_request
      return
    end

    address = Address.where(address: target_address).where(kind: kind).first

    unless address.present?
      # 初回ならデータベースに登録
      address = Address.new(address: target_address, kind: kind.to_i)
      address.save
    end

    # TODO railsのテストコードでsignedが対応されたらテストコードもリファクタリング
    # https://github.com/rails/rails/issues/53207
    session = Session.new(
      address: address,
      chain_id: params[:chain_id],
      message: params[:message],
      signature: params[:signature],
      domain: params[:domain]
    )

    # 値チェック
    unless session.valid?
      emsgs = session.errors.map do |e|
        { msg: e.full_message }
      end
      render json: { errors: emsgs }, status: :bad_request
      return
    end

    verify_params = session.make_verify_params(nonce: cookies.signed[:nonce])

    # 　気がついたエラーを修正
    # 　まずはここのログ
    # 　外部APIに対するログ
    # noceとsesson_idの名称 _hoge_nonce
    # envファイル読み込み

    response = nil
    begin
      response = ChainGate::Repositories::Authentications::Verify.new(params: verify_params).fetch
    rescue => e
      logger.error(e.message)
      render json: { errors: [ { msg: e } ] }, status: :unauthorized
      return
    end

    if response.status_code == 201
      address.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
        chain_id: session.chain_id,
        message: session.message,
        signature: session.signature,
        domain: session.domain).tap do |session|
        # Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    else
      render json: { errors: [ { msg: "ログインに失敗しました" } ] }, status: :unauthorized
      return
    end

    render status: :created
  end

  # post
  def verify
    # session_id = Rails.env.test? ? cookies[:session_id] : cookies.signed[:session_id]
    session_id = cookies.signed[:session_id]
    session = Session.find_by(id: session_id)
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
      return
    end

    render status: :created
  end

  def signout
    # Current.session.destroy
    cookies.delete(:session_id)
    cookies.delete(:nonce)
    render status: :created
  end

  # ユーザー情報を取得
  def user
    session = find_session_by_cookie
    unless session.present?
      # TOD railsでログを出す
      render json: { errors: [ { msg: "権限がありません" } ] }, status: :unauthorized
      return
    end

    render json: { address: session.address.address, omission_address: session.address.matamask_format_address, network: session.network, last_login: session.last_login }, status: :ok
  end
end
