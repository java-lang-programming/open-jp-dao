# -*- coding: utf-8 -*-
from pydantic import BaseModel
from siwe import SiweMessage

class DeployedContracts(BaseModel):
    #　コントラクトアカウント
    ca: str
    returncode: int
    stdout: str

    #　objectに変換
    def data(self):
        return False



    # def create(self, engagement_targets_job_categories: any):
    # def is_worker(self) -> bool:
    #     if self.kind == self.KIND_WORKER_NFT:
    #         return True
    #     return False
    # def create(self, engagement_targets_job_categories: any):
    # https://github.com/spruceid/siwe-py/blob/main/siwe/siwe.py#L283
    # def exe_verify(self) -> None:
    #     print("calling")
    #     # timeを取得する
    #     try:
    #         message: SiweMessage = SiweMessage(message=self.message)
    #         print("calling2")
    #         # print("message.expiration_time")
    #         # print(message.expiration_time)
    #         # expiration_timeが取れる
    #         message.verify(self.signature, nonce=self.nonce, domain=self.domain)
    #         print("calling3")
    #         return message.expiration_time
    #     except siwe.ValueError:
    #         # Invalid message
    #         print("Authentication attempt rejected.")
    #     except siwe.ExpiredMessage:
    #         print("Authentication attempt rejected.")
    #     except siwe.DomainMismatch:
    #         print("Authentication attempt rejected.")
    #     except siwe.NonceMismatch:
    #         print("Authentication attempt rejected.")
    #     except siwe.MalformedSession as e:
    #         # e.missing_fields contains the missing information needed for validation
    #         print("Authentication attempt rejected.")
    #     except siwe.InvalidSignature:
    #         print("Authentication attempt rejected.")

