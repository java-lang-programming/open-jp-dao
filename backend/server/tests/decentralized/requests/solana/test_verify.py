# -*- coding: utf-8 -*-

import pytest
from pydantic import ValidationError
from base58 import b58encode

from src.decentralized.requests.solana.verify import Verify


def test_verify_valid_base58():
    # 正しいBase58の値を作成
    sig = b58encode(b"hello world").decode()

    model = Verify(
        public_key="TestPublicKey",
        signature_b58=sig,
        message="hello"
    )

    assert model.signature_b58 == sig


def test_verify_invalid_base58():
    # Base58 ではありえない文字を含める（0, O, I, l など）
    invalid_sig = "0OIl###"

    with pytest.raises(ValidationError):
        Verify(
            public_key="TestPublicKey",
            signature_b58=invalid_sig,
            message="hello"
        )
