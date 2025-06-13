# routers/sessions.pyのテスト

from fastapi.testclient import TestClient

from unittest.mock import patch

from src.main import app

client = TestClient(app)

# /api/nonceのテスト
def test_api_nonce():
    response = client.get("/api/nonce")
    assert response.status_code == 200
    response_data = response.json()
    # nonce キーが存在することを確認
    assert "nonce" in response_data
    # nonce の値が文字列型であることを確認
    assert isinstance(response_data["nonce"], str)
    # nonce の値が20文字であることを確認
    assert len(response_data["nonce"]) == 20

# パラメーター(entity)がそもそも不正な場合
def test_api_verify_invalid_entity():
    data = {"chain_id": "aaaaa", "message": "aa", "signature": "aaa", "nonce": "aaa", "domain": "local"}
    response = client.post("/api/verify", json=data)
    assert response.status_code == 422

# post /api/verifyでchain_idがinvalidの場合
def test_api_verify_invalid_chain():
    data = {"chain_id": 2, "message": "aa", "signature": "aaa", "nonce": "aaa", "domain": "local"}
    response = client.post("/api/verify", json=data)
    assert response.status_code == 400
    assert response.json() == {'errors': {'code': 'E0000001', 'message': 'chain_id error', 'detail': "ExceptionInvalidChainID('invalid chain id. chain id must be 1 or 8545 or 11155111')"}}

# post /api/verifyでイーサリアムの接続に失敗した場合
def test_api_verify_not_conneced_ethereum():
    data = {"chain_id": 8545, "message": "aa", "signature": "aaa", "nonce": "aaa", "domain": "local"}
    response = client.post("/api/verify", json=data)
    assert response.status_code == 403
    assert response.json() == {'errors': {'code': 'E0000002', 'detail': '接続先のステータスを確認してください', 'message': 'イーサリアムに接続できませんでした'}}

# post /api/verifyでverifyに失敗した場合
def test_api_verify_fails_authorized():
    data = {"chain_id": 8545, "message": "aa", "signature": "aaa", "nonce": "aaa", "domain": "local"}

    with patch('src.routers.sessions.Ethereum') as mock_ethereum_class:
        # 接続true
        mock_ethereum_class.is_connected.return_value = True

        response = client.post("/api/verify", json=data)
        assert response.status_code == 400
        assert response.json() == {'errors': {'code': 'E0000003', 'message': 'SiweMessage verify error', 'detail': 'ValueError()'}}

# post /api/verifyでverifyに成功した場合(mock)
def test_api_verify_success():
    data = {"chain_id": 8545, "message": "aa", "signature": "aaa", "nonce": "aaa", "domain": "local"}

    with patch('src.routers.sessions.Ethereum') as mock_ethereum_class:
        # 接続true
        mock_ethereum_class.is_connected.return_value = True
        with patch('src.routers.sessions.SiweMessage') as mock_siwe_message_class:
            mock_siwe_message_class.from_message.return_value = mock_siwe_message_class
            mock_siwe_message_class.verify.return_value = None

            response = client.post("/api/verify", json=data)
            assert response.status_code == 201
