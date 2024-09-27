# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.open_jp_dao_governor_repository import (
    OpenJpDaoGovernorRepository,
)
from bunsan.ethereum.repositories.erc20_votes_repository import (
    ERC20VotesRepository,
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

            # quorum = openJpDaoRepo

            state = openJpDaoRepo.state(
                proposalId=proposalId, from_address=from_address
            )

            erc20VotesRepository = ERC20VotesRepository(ethereum=self.ethereum)
            mode = erc20VotesRepository.CLOCK_MODE(from_address=from_address)
            clock = erc20VotesRepository.clock(from_address=from_address)
            return {
                "state": state,
                "proposal": {
                    "deadline": proposalDeadline,
                    "snapshot": proposalSnapshot,
                    "proposer": proposalProposer,
                },
                "eip6372": {
                  "clock": clock,
                  "CLOCK_MODE": mode,
                },
                "mata": {
                  "state": {
                    "0": "Pending",
                    "1": "Active [deadline >= currentTimepoint]",
                    "2": "Canceled",
                    "3": "Defeated",
                    "4": "Succeeded",
                    "5": "Queued",
                    "6": "Expired",
                    "7": "Executed",
                  }
                }
            }
        except Exception as e:
            # GovernorNonexistentProposalと判断する方法が必要。
            raise e

# ProposalState {
# #         Pending,  0
# #         Active,   1      proposal作成後にチェーンでトランザクションが実行されるとactiveになる deadline >= currentTimepoint
# #         Canceled,  2
# #         Defeated,  3     2回addしたらなった。
# #         Succeeded,4
# #         Queued, 5
# #         Expired, 6
# #         Executed 7
# #     }

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
