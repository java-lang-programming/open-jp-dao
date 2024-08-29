# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.requests.votes.votes_create import VoteCreateRequest
from decentralized.infrastructures.ethereum.repogitories.open_jp_dao_governor_repository import (
    OpenJpDaoGovernorRepository
)

class VoteCreate:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    #　これは間違っている。
    # , address: str
    def execute(self, voteCreate: VoteCreateRequest):
        print("処理を開始します。")
        print(voteCreate.targets())
        print(voteCreate.call_data())
        print(voteCreate.description)
        # VoteTolen
        # targets = [voteCreate.]
        #　固定
        values = [0]
        openJpDaoRepo = OpenJpDaoGovernorRepository(ethereum=self.ethereum)

        proposalId = openJpDaoRepo.hashProposal(voteCreate.targets(), values, voteCreate.call_data(), voteCreate.description, voteCreate.from_address)
        print(proposalId)
        # proposalId = openJpDaoRepo.propose(voteCreate.targets(), values, voteCreate.call_data(), voteCreate.description, voteCreate.from_address)
        
        return {"proposalId": proposalId}
