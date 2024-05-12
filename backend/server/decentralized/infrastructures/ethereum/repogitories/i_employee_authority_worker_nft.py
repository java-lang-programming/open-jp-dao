# -*- coding: utf-8 -*-

import abc


class IEmployeeAuthorityWorkerNFTRepogitory(metaclass=abc.ABCMeta):
    # @abc.abstractmethod
    # def name(self, from_address: str) -> str:
    #     raise NotImplementedError()

    # @abc.abstractmethod
    # def symbol(self, from_address: str) -> str:
    #     raise NotImplementedError()

    @abc.abstractmethod
    def balanceOf(self, target_address: str, from_address: str) -> int:
        raise NotImplementedError()

    @abc.abstractmethod
    def mintNFT(self, address: str, token_id: int, from_address: str):
        raise NotImplementedError()
