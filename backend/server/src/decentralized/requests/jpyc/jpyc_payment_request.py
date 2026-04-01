# -*- coding: utf-8 -*-
from pydantic import BaseModel


# スキーマ定義
class JPYCPaymentRequest(BaseModel):
    tx_hash: str
    amount: float
    destination_address: str
    chain_id: int


class JPYCPaymentResponse(BaseModel):
    status: str
    message: str
    transaction_id: str
