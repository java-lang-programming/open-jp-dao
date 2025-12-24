# spec/support/login_helpers.rb
module LoginHelpers
  def sign_in_as(address_record:)
    # APIのモック処理
    mock_apis_verify(body: {})
    mock_apis_ens(
      status: 200,
      body: { ens_name: "test.eth" }
    )

    # ログインシーケンス
    get apis_sessions_nonce_path
    post apis_sessions_signin_path, params: {
      address: address_record.address,
      kind: Address.kinds[:ethereum],
      chain_id: 1,
      message: "message",
      signature: "signature",
      domain: "aiueo.com"
    }
  end
end
