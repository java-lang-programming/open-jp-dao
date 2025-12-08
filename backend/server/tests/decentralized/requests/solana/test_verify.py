# -*- coding: utf-8 -*-

import pytest
from pydantic import ValidationError
from base58 import b58encode

from src.decentralized.requests.solana.verify import Verify


# ------- 正常系 -------
def test_verify_success():
    valid_public_key = "4Nd1mXhGJQn7XjHkMuquxYZc13JUon2cChn1ytY1fHxp"  # 実在する有効なBase58のpubkey
    message = "hello"

    signature = b58encode(b"dummy_signature").decode("utf-8")

    model = Verify(
        public_key=valid_public_key,
        signature_b58=signature,
        message=message
    )

    assert model.public_key == valid_public_key
    assert model.signature_b58 == signature
    assert model.message == message

def test_invalid_public_key():
    invalid_public_key = "this_is_invalid"
    signature = b58encode(b"dummy").decode()

    with pytest.raises(ValidationError) as exc:
        Verify(
            public_key=invalid_public_key,
            signature_b58=signature,
            message="hello"
        )

    assert "Invalid public key" in str(exc.value)

def test_invalid_signature_b58():
    valid_public_key = "4Nd1mXhGJQn7XjHkMuquxYZc13JUon2cChn1ytY1fHxp"
    invalid_signature = "!!!!not_base58!!!!"

    with pytest.raises(ValidationError) as exc:
        Verify(
            public_key=valid_public_key,
            signature_b58=invalid_signature,
            message="hello"
        )

    assert "Invalid signature (not base58)" in str(exc.value)
