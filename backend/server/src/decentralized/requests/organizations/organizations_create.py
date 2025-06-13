# -*- coding: utf-8 -*-
from pydantic import BaseModel


class OrganizationsCreate(BaseModel):
    chain_id: int
    owner_address: str
    # name: str
    # summary: str# optionak
