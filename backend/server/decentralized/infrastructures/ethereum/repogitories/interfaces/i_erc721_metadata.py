# -*- coding: utf-8 -*-

import abc


class IERC721Metadata(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def name(self, from_address: str) -> str:
        raise NotImplementedError()

    @abc.abstractmethod
    def symbol(self, from_address: str) -> str:
        raise NotImplementedError()

    @abc.abstractmethod
    def tokenURI(self, token_id: int, from_address: str) -> str:
        raise NotImplementedError()

    # @abc.abstractmethod
    # def mintNFT(self, address: str, token_id: int, from_address: str):
    #     raise NotImplementedError()
