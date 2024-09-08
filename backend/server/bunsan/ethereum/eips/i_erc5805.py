# -*- coding: utf-8 -*-

import abc

# https://eips.ethereum.org/EIPS/eip-5805
class IERC5805(metaclass=abc.ABCMeta):

    @abc.abstractmethod
    def eventDelegateChanged():
        raise NotImplementedError()

    @abc.abstractmethod
    def getVotes(self, tagret_address: str, from_address: str) -> int:
        raise NotImplementedError()

    @abc.abstractmethod
    def getPastVotes(self, tagret_address: str, timepoint: int, from_address: str) -> str:
        raise NotImplementedError()

    @abc.abstractmethod
    def delegate(self, delegatee_address: str, from_address: str):
        raise NotImplementedError()

    @abc.abstractmethod
    def delegates(self, tagret_address: str, from_address: str) -> str:
        raise NotImplementedError()
