# -*- coding: utf-8 -*-
from pydantic import BaseModel


class VoteCastRequest(BaseModel):
    support: int
