# -*- coding: utf-8 -*-
from dataclasses import dataclass, asdict
from typing import TypedDict, Dict, cast


class ErrorDict(TypedDict):
    code: int
    message: str
    detail: str


@dataclass
class Errors:
    code: int
    message: str
    detail: str

    def to_dict(self) -> ErrorDict:
        return cast(ErrorDict, asdict(self))

    # エラーレスポンスを作成する
    def create(self) -> Dict[str, list[ErrorDict]]:
        return {"errors": [self.to_dict()]}


class ErrorCodes:
    # 不正なchainID
    INVALID_CHAIN_ID: str = "E0000001"
    # イーサリアムに接続できない
    NOT_CONNECTED_ETHEREUM = "E0000002"
    # SiweMessage　verifyエラー
    SIWE_MESSAGE_VERIFY_ERROR = "E0000003"
    # アドレスのフォーマットエラー
    INVALID_FORMAT_ADDRESS_ERROR = "E0000004"
    # votec createのエラー
    ERROR_VOTE_CREATE = "EVC00001"
    # votec showのエラー
    ERROR_VOTE_SHOW = "EVS00001"
    # solana verifyエラー
    SOLANA_VERIFY_ERROR = "S0000001"
