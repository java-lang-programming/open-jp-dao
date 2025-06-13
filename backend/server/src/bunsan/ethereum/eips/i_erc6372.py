# -*- coding: utf-8 -*-

import abc


# https://eips.ethereum.org/EIPS/eip-6372
class IERC6372(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def clock(self, from_address: str) -> int:
        raise NotImplementedError()

    @abc.abstractmethod
    def CLOCK_MODE(from_address: str) -> str:
        raise NotImplementedError()
