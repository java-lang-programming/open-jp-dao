# -*- coding: utf-8 -*-
from pydantic import BaseModel


class Nonce(BaseModel):
    chainId: int
    address: str
