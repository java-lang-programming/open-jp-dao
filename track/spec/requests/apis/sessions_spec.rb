require 'rails_helper'

RSpec.describe "Apis::SessionsController", type: :request do
  describe "Get /nonce" do
    context "fetch nonce" do
      it "returns http ok" do
        get apis_sessions_nonce_path
        json = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "Post /signin" do
    let(:addresses_eth) { create(:addresses_eth) }

    context "failure" do
      # 　addressがない
      it "returns status code bad request when address is empty." do
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "addressは必須パラメーターです" } ] })
      end

      context "kind" do
        # kindが未入力
        it "returns status code bad request when kind is empty." do
          mock_apis_verify(body: {})
          get apis_sessions_nonce_path
          post apis_sessions_signin_path, params: { address: "0xaaaa", chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "kindは必須入力です" } ] })
        end

        # kindが布石な値
        it "returns status code bad request when kind is empty." do
          mock_apis_verify(body: {})
          get apis_sessions_nonce_path
          post apis_sessions_signin_path, params: { address: "0xaaaa", kind: 3, chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "kindが不正な値です" } ] })
        end
      end

      context "session" do
        it "returns status code bad request when message is empty." do
          mock_apis_verify(body: {})
          get apis_sessions_nonce_path
          post apis_sessions_signin_path, params: { address: "0xaaaa", kind: Address.kinds[:ethereum], chain_id: 1, signature: "signature", domain: "aiueo.com" }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "Message can't be blank" } ] })
        end

        it "returns status code bad request when signature is empty." do
          mock_apis_verify(body: {})
          get apis_sessions_nonce_path
          post apis_sessions_signin_path, params: { address: "0xaaaa", kind: Address.kinds[:ethereum], chain_id: 1,  message: "message", domain: "aiueo.com" }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "Signature can't be blank" } ] })
        end
      end
    end
    # https://qiita.com/piggydev/items/a6b2bb4601255e173104
    context "success" do
      # 　初回ログイン
      it "returns status code craeted." do
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        json = JSON.parse(response.body, symbolize_names: true)
        post apis_sessions_signin_path, params: { address: "0xaaaa", kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
        expect(response).to have_http_status(:created)
        session = Address.where(address: "0xaaaa").first.sessions.first
        expect(session.chain_id).to eq(1)
        expect(session.message).to eq("message")
        expect(session.signature).to eq("signature")
      end

      # ２回目以降のログイン
      it "returns status code craeted." do
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
        session = addresses_eth.sessions.first
        expect(response).to have_http_status(:created)
        expect(session.chain_id).to eq(1)
        expect(session.message).to eq("message")
        expect(session.chain_id).to eq(1)
        expect(session.signature).to eq("signature")
        expect(session.domain).to eq("aiueo.com")
      end
    end
  end

  describe "Post /verify" do
    let(:addresses_eth) { create(:addresses_eth) }

    context "success" do
      it "returns status code craeted." do
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
        post apis_sessions_verify_path
      end
    end

    context "failure" do
      # session_idなし
      it "returns status code unauthorized." do
        post apis_sessions_verify_path
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "Post /signout" do
    let(:addresses_eth) { create(:addresses_eth) }

    context "success" do
      # session_idなし
      it "returns status code unauthorized." do
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
        post apis_sessions_signout_path
      end
    end
  end

  describe "Get /user" do
    context "failure" do
      # session_idなし
      it "returns status code unauthorized." do
        get apis_sessions_user_path
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to eq({ errors: [ { msg: "権限がありません" } ] })
      end
    end

    context "success" do
      let(:addresses_eth) { create(:addresses_eth) }

      before do
        # sigin処理
        mock_apis_verify(body: {})
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: Session::ETHEREUM_SEPOLIA, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      it "returns status code ok." do
        get apis_sessions_user_path
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:address]).to eq(addresses_eth.address)
        expect(json[:network]).to eq("Ethereum Sepolia")
        expect(json[:last_login].size).to eq(19)
      end
    end
  end

  # GODO factory
  def dummy
    # {"chain_id":"11155111","message":"http://localhost:3010 wants you to sign in with your Ethereum account:\n0x91582E868c62FA205d38BeBaB7B903322A4CC89D\n\nSign in with Ethereum to the app.\n\nURI: http://localhost:3010\nVersion: 1\nChain ID: 11155111\nNonce: abcdefghajklnlopqA\nIssued At: 2024-12-08T00:02:16.652Z","signature":"0xebf27824d7df2bfeaf69104a306aa3e178616d1903e6136f0eccb18fc05b97fc53dd030ede83131415d1beb089962809dd376067f76cce9d688cee7e9c3760371b","nonce":"abcdefghajklnlopqA","domain":"localhost:3010"}
  end
end
