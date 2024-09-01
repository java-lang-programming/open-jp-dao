# -*- coding: utf-8 -*-


class Errors:
    code: int
    message: str
    detail: str

    def __init__(self, code: str, message: str, detail: str):
        self.code = code
        self.message = message
        self.detail = detail

    # def create(self, engagement_targets_job_categories: any):
    def to_dict(self) -> dict:
        error: dict = {}
        error["code"] = self.code
        error["message"] = self.message
        error["detail"] = self.detail
        errors: dict = {}
        errors["errors"] = error
        return errors


class ErrorCodes:
    # 不正なchainID
    INVALID_CHAIN_ID: str = "E0000001"
    # イーサリアムに接続できない
    NOT_CONNECTED_ETHEREUM = "E0000002"
    # votec createのエラー
    ERROR_VOTE_CREATE = "EVC00001"
    # votec showのエラー
    ERROR_VOTE_SHOW = "EVS00001"
