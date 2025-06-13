# -*- coding: utf-8 -*-

import abc


# https://eips.ethereum.org/EIPS/eip-20
# https://docs.openzeppelin.com/contracts/4.x/api/token/erc20#IERC20
class IERC20(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def eventTransfer():
        raise NotImplementedError()

    @abc.abstractmethod
    def balanceOf(self, target_address: str, from_address: str) -> int:
        """
        Returns the amount of tokens owned by account.
        """
        raise NotImplementedError()

    @abc.abstractmethod
    def transfer(self, to_address: str, amount: int, from_address: str):
        """
        Moves amount tokens from the caller’s account to to.
        Returns a boolean value indicating whether the operation succeeded.
        """
        raise NotImplementedError()
