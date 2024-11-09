API設計

# apis/session/nonce

bundle exec rails g controller apis/sessions nonce verify

curl "http://localhost:3000/apis/sessions/nonce" -c cookie
http://localhost:3000/apis/sessions/nonce

sesseonにnonceを保存

class Session::Nonce



  def index
     call python nonce
     session[:nonce] = nonce

  end


end 

/sesion/verify

curl -b cookie -X POST "http://localhost:3000/apis/sessions/verify"

/session/signout



