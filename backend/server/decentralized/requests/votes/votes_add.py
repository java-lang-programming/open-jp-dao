# -*- coding: utf-8 -*-
from pydantic import BaseModel


class VoteAddRequest(BaseModel):
    to: str
    amount: int
