require "rbnacl"
require "base58"

class Apis::SolanaController < ApplicationController

  def signin
    # addressを意味する
    target_address = params[:public_key]
    unless target_address.present?
      # これはイーサリアムと共通
      return render json: { errors: [ { msg: "addressは必須パラメーターです" } ] }, status: :bad_request
    end

    kind = params[:kind]
    errors = Address.kind_errors(kind: kind)
    if errors.present?
      return render json: { errors: errors.map { |e| { msg: e } } }, status: :bad_request
    end

    # 　ここはsolana固定で
    address = Address.where(address: target_address).where(kind: kind).first

    unless address.present?
      # 初回ならデータベースに登録
      address = Address.new(address: target_address, kind: kind.to_i)
      address.save
    end

    # SNS情報を取得して更新する(処理の時間がかかるので非同期) まずはdevに繋ぐ
    session = Session.new(
      address: address,
      chain_id: nil,
      message: params[:message],
      signature: params[:signature_b58],
      domain: nil
    )

    # 値チェック
    unless session.valid?
      emsgs = session.errors.map do |e|
        { msg: e.full_message }
      end
      render json: { errors: emsgs }, status: :bad_request
      return
    end

    verify_params = {
      public_key: target_address,
      signature_b58: session.signature,
      message: session.message + "改ざん"
    }

    puts "verify_params"
    puts verify_params.inspect

    response = ChainGate::Repositories::Solana::Verify.new(params: verify_params).fetch

    if response.status_code == 200
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
      puts "こっち"
      # TODO 例外をログに出すよ
      render json: { errors: [ { msg: "ログイン認証に失敗しました" } ] }, status: :unauthorized
      return
    end

    render status: :created
  end

  private

  def address_params
    params.require(:address).permit(:address, :kind)
  end
end
