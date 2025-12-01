# routers/solana.pyのテスト

import os
import base58
import pytest

from fastapi.testclient import TestClient

from unittest.mock import patch

from src.main import app


client = TestClient(app)

# ---------- 共通データ ----------
@pytest.fixture
def valid_public_key():
    # 32byte を base58 で encode → valid Solana public key
    key_bytes = os.urandom(32)
    return base58.b58encode(key_bytes).decode()


@pytest.fixture
def valid_signature():
    sig = os.urandom(64)
    return base58.b58encode(sig).decode()


@pytest.fixture
def valid_message():
    return "hello solana"


# ---------- 正常系 ----------
def test_verify_success(valid_public_key, valid_signature, valid_message):
    payload = {
        "public_key": valid_public_key,
        "signature_b58": valid_signature,
        "message": valid_message,
    }

    # verify_signature を常に None に mock
    with patch("src.routers.solana.verify_signature", return_value=None):
        res = client.post("/api/solana/verify", json=payload)

    assert res.status_code == 200
    assert res.json() == {"verified": True}

# ---------- 異常系：public key validation ----------
def test_invalid_public_key(valid_signature, valid_message):
    payload = {
        "public_key": "BAD",   # validator で確実にNG
        "signature_b58": valid_signature,
        "message": valid_message,
    }

    res = client.post("/api/solana/verify", json=payload)

    assert res.status_code == 422
    assert "Invalid public key" in str(res.json())

# ---------- 異常系：signature_b58 validation ----------
def test_invalid_signature_b58(valid_public_key, valid_message):
    payload = {
        "public_key": valid_public_key,
        "signature_b58": "!!!!",  # base58 として decode 不可
        "message": valid_message,
    }

    res = client.post("/api/solana/verify", json=payload)

    assert res.status_code == 422
    assert "Invalid signature" in str(res.json())

# ---------- 異常系：verify_signature が例外 ----------
def test_verify_signature_raises(valid_public_key, valid_signature, valid_message):
    payload = {
        "public_key": valid_public_key,
        "signature_b58": valid_signature,
        "message": valid_message,
    }

    # verify_signature が例外を投げるよう mock
    with patch("src.routers.solana.verify_signature", side_effect=Exception("boom")):
        res = client.post("/api/solana/verify", json=payload)

    assert res.status_code == 400
    assert "solana verify error" in res.json()["errors"]["message"]

# ---------- 異常系：verify_signature が None 以外 ----------
def test_verify_signature_invalid(valid_public_key, valid_signature, valid_message):
    payload = {
        "public_key": valid_public_key,
        "signature_b58": valid_signature,
        "message": valid_message,
    }

    # result != None → signature invalid
    with patch("src.routers.solana.verify_signature", return_value="INVALID"):
        res = client.post("/api/solana/verify", json=payload)

    assert res.status_code == 400
    assert "signature invalid" in res.json()["errors"]["detail"]
