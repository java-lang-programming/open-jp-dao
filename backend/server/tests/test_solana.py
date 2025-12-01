# routers/solana.pyのテスト

from fastapi.testclient import TestClient

from unittest.mock import patch

from src.main import app

from src.decentralized.responses.errors import ErrorCodes

client = TestClient(app)

# -------------------------
# 正常系：署名が正しい場合
# -------------------------
@patch("src.routers.solana.verify_signature", return_value=None)
@patch("src.routers.solana.PublicKey", return_value="MockedPublicKey")
def test_verify_success(mock_pubkey, mock_verify_sig):
    body = {
        "public_key": "ExamplePublicKey",
        "signature_b58": "3MNQE1X",  # valid-ish base58 (簡易でOK)
        "message": "hello"
    }

    response = client.post("/api/solana/verify", json=body)

    assert response.status_code == 200
    assert response.json() == {"verified": True}

    mock_verify_sig.assert_called_once()

# TODO publiv keyのチェック
# signatureのチェックも必要
# -------------------------
# 異常系：verify_signature が False を返す
# -------------------------
@patch("src.routers.solana.verify_signature", return_value=False)
@patch("src.routers.solana.PublicKey", return_value="MockedPublicKey")
def test_verify_invalid_signature(mock_pubkey, mock_verify_sig):
    body = {
        "public_key": "ExamplePublicKey",
        "signature_b58": "3MNQE1X",
        "message": "hello"
    }

    response = client.post("/api/solana/verify", json=body)

    assert response.status_code == 400  # SolanaVerifyException の想定
    data = response.json()

    assert data["errors"]["code"] == ErrorCodes.SOLANA_VERIFY_ERROR
    assert data["errors"]["message"] == "solana verify error"

    mock_verify_sig.assert_called_once()
