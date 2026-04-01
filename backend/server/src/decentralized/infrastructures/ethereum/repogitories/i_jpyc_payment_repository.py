# -*- coding: utf-8 -*-

import abc


class IJpycPaymentRepository(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def isActive(self, user_address: str) -> bool:
        """ユーザーの有効期限が現在時刻を超えているか確認"""
        raise NotImplementedError()

    @abc.abstractmethod
    def getUserExpiry(self, user_address: str) -> int:
        """ユーザーの有効期限（Unixタイムスタンプ）を取得"""
        raise NotImplementedError()

    # @abc.abstractmethod
    # def payOneMonth(self, from_private_key: str) -> str:
    #     """1ヶ月分の支払いコントラクトを実行し、tx_hashを返す"""
    #     raise NotImplementedError()

    @abc.abstractmethod
    def getSubscriptionPaidLogs(
        self, from_block: int, to_block: str = "latest"
    ) -> list[dict]:
        """SubscriptionPaidイベントをスキャンして取得"""
        raise NotImplementedError()
