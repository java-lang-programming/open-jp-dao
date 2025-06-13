# -*- coding: utf-8 -*-
from pydantic import BaseModel


class VoteCreateRequest(BaseModel):
    # NFT worker
    CALL_DATE_TYPE_NO_DATA: int = 1
    CALL_DATE_TYPE_NO_TRANSFER: int = 2

    chain_id: int
    # owner_address: str
    token_address: str
    call_data_type: int
    description: str
    from_address: str

    def call_data(self) -> list[str]:
        if self.call_data_type == self.CALL_DATE_TYPE_NO_DATA:
            return ["0x"]
        elif self.call_data_type == self.CALL_DATE_TYPE_NO_TRANSFER:
            return ["0x"]
        return ["0x"]

    # taggetsの取得
    # targets: list[str]
    def targets(self) -> list[str]:
        return [self.token_address]

    # # TODO hsh
    # def description(self) -> str:
    #   return self.description

    # name: str
    # summary: str# optionak

    # [VoteToken.address],
    # [0],
    # [transferCalldata],
    # "Proposal #1: Give grant to team",
