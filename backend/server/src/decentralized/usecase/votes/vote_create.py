# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.requests.votes.votes_create import VoteCreateRequest
from decentralized.infrastructures.ethereum.repogitories.open_jp_dao_governor_repository import (
    OpenJpDaoGovernorRepository,
)
from bunsan.ethereum.exceptions.governor.exception_snapshot import ExceptionSnapshot


# proposalにする
class VoteCreate:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    # 　これは間違っている。
    # , address: str
    def execute(self, voteCreate: VoteCreateRequest):
        print("処理を開始します。")
        print(voteCreate.targets())
        print(voteCreate.call_data())
        print(voteCreate.description)
        # VoteTolen
        # targets = [voteCreate.]
        # 　固定
        values = [0]
        openJpDaoRepo = OpenJpDaoGovernorRepository(ethereum=self.ethereum)

        proposalId = openJpDaoRepo.hashProposal(
            targets=voteCreate.targets(),
            values=values,
            calldatas=voteCreate.call_data(),
            description=voteCreate.description,
            from_address=voteCreate.from_address,
        )
        proposalSnapshot = openJpDaoRepo.proposalSnapshot(
            proposalId=proposalId, from_address=voteCreate.from_address
        )
        if proposalSnapshot != 0:
            # すでに存在している。descriptionを変える必要がある。
            raise ExceptionSnapshot("proposalSnapshot is not zero.")

        # proposalId = openJpDaoRepo.hashProposal(voteCreate.targets(), values, voteCreate.call_data(), voteCreate.description, voteCreate.from_address)
        newProposalId = openJpDaoRepo.propose(
            voteCreate.targets(),
            values,
            voteCreate.call_data(),
            voteCreate.description,
            voteCreate.from_address,
        )
        print(newProposalId)

        return {"proposalId": newProposalId}
