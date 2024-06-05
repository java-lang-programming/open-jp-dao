# -*- coding: utf-8 -*-
from pydantic import BaseModel


class Nft(BaseModel):
    kind: int
    address: str
    chain_id: int

    # def create(self, engagement_targets_job_categories: any):
    def is_worker(self) -> bool:
        if self.kind == 1:
            return True
        return False
