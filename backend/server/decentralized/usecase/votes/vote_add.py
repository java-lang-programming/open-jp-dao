# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.requests.votes.votes_add import VoteAddRequest
from bunsan.ethereum.repositories.erc20_votes_repository import (
    ERC20VotesRepository,
)


class VoteAdd:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    # , address: str
    def execute(self, request: VoteAddRequest, from_address: str):
        try:
            # balance check
            erc20VotesRepository = ERC20VotesRepository(ethereum=self.ethereum)
            from_address_balance = erc20VotesRepository.balanceOf(
                target_address=from_address, from_address=from_address
            )
            if from_address_balance < request.amount:
                # ExceptionInsufficientBalance
                raise Exception("ExceptionInsufficientBalance")
            erc20VotesRepository.setVote(
                to_address=request.to, amount=request.amount, from_address=from_address
            )
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
