# -*- coding: utf-8 -*-
from pydantic import BaseModel, field_validator
from solathon.publickey import PublicKey
import base58


class Verify(BaseModel):
    public_key: str
    signature_b58: str
    message: str

    @field_validator("public_key")
    def validate_public_key(cls, v):
        try:
            PublicKey(v)
        except Exception:
            raise ValueError("Invalid public key")
        return v

    @field_validator("signature_b58")
    def validate_b58(cls, v):
        try:
            base58.b58decode(v)
        except Exception:
            raise ValueError("Invalid signature (not base58)")
        return v
