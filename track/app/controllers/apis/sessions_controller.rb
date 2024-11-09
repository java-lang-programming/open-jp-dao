class Apis::SessionsController < ApplicationController
  # https://zenn.dev/makoto00000/articles/843b7f164b4ddd
  # https://office54.net/iot/programming/http-stateless-session セッションは的まえる
  def nonce
    # response = Web3::Repositories::Authentications::Nonce.new.fetch
    # nonce = response.nonce

    # 　成功の場合のjsonと失敗の場合のjsonの処理を記載する
    # 　ここでapiをcall
    nonce = "aaaaaaaaa"
    session[:nonce] = nonce
    render status: :ok, json: { nonce: nonce }
  end

  def verify
    nonce = session[:nonce]
    puts "nonce"
    puts nonce
    render status: :created
  end

  def signout
    reset_session
    render status: :created
  end
end
