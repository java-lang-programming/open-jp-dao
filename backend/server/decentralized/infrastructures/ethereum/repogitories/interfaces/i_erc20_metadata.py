# -*- coding: utf-8 -*-

import abc


# https://docs.openzeppelin.com/contracts/4.x/api/token/erc20#IERC20Metadata
class IERC20Metadata(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def name(self, from_address: str) -> str:
        """
        Returns the name of the token.
        """
        raise NotImplementedError()

    @abc.abstractmethod
    def symbol(self, from_address: str) -> str:
        """
        Returns the symbol of the token.
        """
        raise NotImplementedError()
