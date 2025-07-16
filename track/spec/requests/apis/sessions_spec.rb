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
        before do
          mock_apis_verify(body: {})
        end

        # kindが未入力
        it "returns status code bad request when kind is empty." do
          get apis_sessions_nonce_path
          post apis_sessions_signin_path, params: { address: "0xaaaa", chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "kindは必須入力です" } ] })
        end

        # kindが布石な値
        it "returns status code bad request when kind is empty." do
          get apis_sessions_nonce_path
          post apis_sessions_signin_path, params: { address: "0xaaaa", kind: 3, chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "kindが不正な値です" } ] })
        end
      end

      context "session" do
        before do
          mock_apis_verify(body: {})
          mock_apis_ens(
            status: 200,
            body: { ens_name: "test.eth" }
          )
        end

        it "returns status code bad request when message is empty." do
          get apis_sessions_nonce_path
          post apis_sessions_signin_path, params: { address: "0xaaaa", kind: Address.kinds[:ethereum], chain_id: 1, signature: "signature", domain: "aiueo.com" }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json).to eq({ errors: [ { msg: "Message can't be blank" } ] })
        end

        it "returns status code bad request when signature is empty." do
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
      before do
        mock_apis_verify(body: {})
      end

      # 初回ログイン
      it "returns status code craeted." do
        mock_apis_ens(
          status: 200,
          body: { ens_name: "test.eth" }
        )
        get apis_sessions_nonce_path
        json = JSON.parse(response.body, symbolize_names: true)
        post apis_sessions_signin_path, params: { address: "0xaaaa", kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }
        expect(response).to have_http_status(:created)

        # 値の確認
        address = Address.where(address: "0xaaaa").first
        # ここは非同期
        # expect(address.ens_name).to eq("test.eth")
        expect(address.ens_name).to be nil
        session = address.sessions.first
        expect(session.chain_id).to eq(1)
        expect(session.message).to eq("message")
        expect(session.signature).to eq("signature")
      end

      # ２回目以降のログイン
      context "success login not firsr" do
        it "returns status code craeted and update ens_name" do
          mock_apis_ens(
            status: 200,
            body: { ens_name: "test.eth" }
          )
          get apis_sessions_nonce_path
          post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }

          # 値の確認
          session = addresses_eth.sessions.first
          expect(response).to have_http_status(:created)

          # 更新データ取得
          temp_address = Address.where(id: addresses_eth.id).first

          # ここは非同期
          # expect(temp_address.ens_name).to eq("test.eth")
          expect(temp_address.ens_name).to be nil
          expect(session.chain_id).to eq(1)
          expect(session.message).to eq("message")
          expect(session.chain_id).to eq(1)
          expect(session.signature).to eq("signature")
          expect(session.domain).to eq("aiueo.com")
        end

        it "returns status code craeted and update ens_name empty" do
          mock_apis_ens(
            status: 200,
            body: { ens_name: nil }
          )
          get apis_sessions_nonce_path
          post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: 1, message: "message", signature: "signature", domain: "aiueo.com" }

          # 値の確認
          session = addresses_eth.sessions.first
          expect(response).to have_http_status(:created)

          # 更新データ取得
          temp_address = Address.where(id: addresses_eth.id).first

          expect(temp_address.ens_name).to be nil
          expect(session.chain_id).to eq(1)
          expect(session.message).to eq("message")
          expect(session.chain_id).to eq(1)
          expect(session.signature).to eq("signature")
          expect(session.domain).to eq("aiueo.com")
        end
      end
    end
  end

  describe "Post /verify" do
    let(:addresses_eth) { create(:addresses_eth) }

    context "success" do
      it "returns status code craeted." do
        mock_apis_verify(body: {})
        mock_apis_ens(
          status: 200,
          body: { ens_name: "test.eth" }
        )
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
        mock_apis_ens(
          status: 200,
          body: { ens_name: "test.eth" }
        )
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
        mock_apis_ens(
          status: 200,
          body: { ens_name: "test.eth" }
        )
        get apis_sessions_nonce_path
        post apis_sessions_signin_path, params: { address: addresses_eth.address, kind: Address.kinds[:ethereum], chain_id: Session::ETHEREUM_SEPOLIA, message: "message", signature: "signature", domain: "aiueo.com" }
      end

      it "returns status code ok." do
        get apis_sessions_user_path
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:address]).to eq(addresses_eth.address)
        expect(json[:display_address]).to eq(addresses_eth.ens_name)
        expect(json[:network]).to eq("Sepolia")
        expect(json[:last_login].size).to eq(19)
      end
    end
  end
end
