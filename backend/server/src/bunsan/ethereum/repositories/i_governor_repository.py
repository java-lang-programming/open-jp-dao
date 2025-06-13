# -*- coding: utf-8 -*-

import abc


# https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/governance/IGovernor.sol
# versionの差分をどうするか
# v5.0.2
class IGovernorRepository(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def hasVoted(self, proposalId: int, target_address: str, from_address: str) -> bool:
        raise NotImplementedError()

    @abc.abstractmethod
    def propose(
        self,
        targets: list[str],
        values: list[int],
        calldatas: str,
        description: str,
        from_address: str,
    ) -> int:
        raise NotImplementedError()

    @abc.abstractmethod
    def proposalDeadline(proposalId: int, from_address: str) -> int:
        raise NotImplementedError()

    @abc.abstractmethod
    def proposalSnapshot(self, proposalId: int, from_address: str) -> int:
        raise NotImplementedError()

    # https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalProposer-uint256-
    @abc.abstractmethod
    def proposalProposer(self, proposalId: int, from_address: str) -> str:
        raise NotImplementedError()

    @abc.abstractmethod
    def hashProposal(
        self,
        targets: list[str],
        values: list[int],
        calldatas: str,
        description: str,
        from_address: str,
    ) -> int:
        raise NotImplementedError()

    @abc.abstractmethod
    def castVote(self, proposalId: int, support: int, from_address: str) -> int:
        raise NotImplementedError()

    @abc.abstractmethod
    def state(self, proposalId: int, from_address: str) -> int:
        raise NotImplementedError()

    @abc.abstractmethod
    def clock(self, from_address: str) -> int:
        raise NotImplementedError()
