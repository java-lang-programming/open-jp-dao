# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.open_jp_dao_governor_repository import (
    OpenJpDaoGovernorRepository,
)
from bunsan.ethereum.exceptions.governor.exception_snapshot import ExceptionSnapshot


class VoteShow:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    # , address: str
    def execute(self, proposalId: int, from_address: str):
        try:
            openJpDaoRepo = OpenJpDaoGovernorRepository(ethereum=self.ethereum)

            proposalDeadline = openJpDaoRepo.proposalDeadline(
                proposalId=proposalId, from_address=from_address
            )
            proposalSnapshot = openJpDaoRepo.proposalSnapshot(
                proposalId=proposalId, from_address=from_address
            )
            if proposalSnapshot == 0:
                # 提案がない
                raise ExceptionSnapshot("proposalSnapshot is zero.")

            # print(clockMode)
            # 　コントkラウトで実装されている
            # 　まだblockが進んでいないのでは？
            # if proposalSnapshot == 0:
            #  return { "revort": "GovernorNonexistentProposal" }
            # revert GovernorNonexistentProposal(proposalId);

            proposalProposer = openJpDaoRepo.proposalProposer(
                proposalId=proposalId, from_address=from_address
            )
            state = openJpDaoRepo.state(
                proposalId=proposalId, from_address=from_address
            )
            return {
                "state": state,
                "proposal": {
                    "deadline": proposalDeadline,
                    "snapshot": proposalSnapshot,
                    "proposer": proposalProposer,
                },
            }
        except Exception as e:
            # GovernorNonexistentProposalと判断する方法が必要。
            raise e


# show

# proposal_id


# proposalSnapshot
# proposalDeadline
# proposalProposer

# {

#   voting {
#     perood;
#     Delay
#   }

#   quorum:

#   proposal: {
#     snapshot:
#     deadline:
#     Proposer:
#   }

#   proposalVotes
# }


# votingPeriod
