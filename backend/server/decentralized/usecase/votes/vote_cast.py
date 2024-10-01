# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.requests.votes.votes_cast import VoteCastRequest
from decentralized.infrastructures.ethereum.repogitories.open_jp_dao_governor_repository import (
    OpenJpDaoGovernorRepository,
)


class VoteCast:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    # 　これは間違っている。
    # , address: str
    def execute(self, voteCast: VoteCastRequest, proposalId: int, from_address: str):

        # hasvoted

        # VoteTolen
        # targets = [voteCreate.]
        # 　固定
        values = [0]
        openJpDaoRepo = OpenJpDaoGovernorRepository(ethereum=self.ethereum)
        try:
            dao.castVote(proposalId=proposalId, support=voteCast.support, from_address=from_address)
        except Exception as e:
            # GovernorNonexistentProposalと判断する方法が必要。
            raise e

        return {"proposalId": proposalId}
