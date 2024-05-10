# -*- coding: utf-8 -*-

import abc


class IEmployeeAuthorityWorkerNFTRepogitory(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def name(self) -> None:
        raise NotImplementedError()

    @abc.abstractmethod
    def symbol(self) -> None:
        raise NotImplementedError()

    @abc.abstractmethod
    def balanceOf(self, address: str) -> None:
        raise NotImplementedError()
