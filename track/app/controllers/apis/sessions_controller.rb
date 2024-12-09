class Apis::SessionsController < ApplicationController
  include ActionController::Cookies
  # https://zenn.dev/makoto00000/articles/843b7f164b4ddd
  # https://office54.net/iot/programming/http-stateless-session セッションは的まえる
  def nonce
    nonce = "abcdefghajklnlopqA"
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
    chain_id = params[:chain_id]
    message = params[:message]
    signature = params[:signature]
    domain = params[:domain]
    nonce = cookies.signed[:nonce]

    # 　せっしおからnonceを取得
    data = {
      chain_id: chain_id,
      message: message,
      signature: signature,
      nonce: nonce,
      domain: domain
    }

    # 　気がついたエラーを修正
    # 　まずはここのログ
    # 　外部APIに対するログ
    # origin
    # 上記のadddress kindチェックメッセージ
    # noceとsesson_idの名称 _hoge_nonce
    # apisでなくapi問題
    # envファイルよみこmj

    puts data

    response = ChainGate::Repositories::Authentications::Verify.new(params: data).fetch

    status = response.status_code
    if status == 201
      address.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
        chain_id: chain_id,
        message: message,
        signature: signature,
        domain: domain).tap do |session|
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
    session_id = Rails.env.test? ? cookies[:session_id] : cookies.signed[:session_id]
    session = Session.find_by(id: session_id)
    unless session.present?
      render json: { errors: [ { msg: "権限がありません" } ] }, status: :unauthorized
      return
    end

    chain_id = session.chain_id
    message = session.message
    signature = session.signature
    domain = session.domain
    nonce = Rails.env.test? ? cookies[:nonce] : cookies.signed[:nonce]


    # session.to

    # data = {
    #   chain_id: 1,
    # }

    # session.to_json


    # data.to_json


    # chain_id = params[:chain_id]
    # message = params[:message]
    # chain_id: chainId, message: message, signature: signature, nonce: nonce_result.nonce, domain:  domain

    # cookies.delete(:session_id)
    # cookies.signed.permanent[:session_id] = 1
    # 　これは外を呼び出す

    render status: :created
  end

  # これは間違いない
  def signout
    # Current.session.destroy
    cookies.delete(:session_id)
    cookies.delete(:nonce)
    render status: :created
  end
end
