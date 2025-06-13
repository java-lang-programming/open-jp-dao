# -*- coding: utf-8 -*-
from pydantic import BaseModel


class Nft(BaseModel):
    # NFT worker
    KIND_WORKER_NFT: int = 1
    KIND_HOLDER_NFT: int = 2

    kind: int
    targetAddress: str
    # コントラクトの実行アドレス
    fromAddress: str
    chainId: int

    # def create(self, engagement_targets_job_categories: any):
    def is_worker(self) -> bool:
        if self.kind == self.KIND_WORKER_NFT:
            return True
        return False

    # def is_holder(self) -> bool:
    #     if self.kind == Nft.KIND_HOLDER_NFT:
    #         return True
    #     return False
