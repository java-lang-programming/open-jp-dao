# -*- coding: utf-8 -*-
from pydantic import BaseModel, validator
import base58


class Verify(BaseModel):
    public_key: str
    signature_b58: str
    message: str

    @validator("signature_b58")
    def validate_b58(cls, v):
        base58.b58decode(v)  # decodeできなければValidationError
        return v
