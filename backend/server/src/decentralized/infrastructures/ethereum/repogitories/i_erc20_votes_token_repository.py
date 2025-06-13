# -*- coding: utf-8 -*-

import abc


class IERC20VotesTokenRepository(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def mint(self, target_address: str, amount: int, from_address: str):
        raise NotImplementedError()
