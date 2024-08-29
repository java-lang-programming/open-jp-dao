# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.open_jp_dao_governor_repository import (
    OpenJpDaoGovernorRepository
)

class VoteShow:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    # , address: str
    def execute(self, proposalId: int, from_address: str):
        try:
          openJpDaoRepo = OpenJpDaoGovernorRepository(ethereum=self.ethereum)
          proposalDeadline = openJpDaoRepo.proposalDeadline(proposalId=proposalId, from_address=from_address)
          proposalSnapshot = openJpDaoRepo.proposalSnapshot(proposalId=proposalId, from_address=from_address)

          clock = openJpDaoRepo.clock(from_address=from_address)
          print(clock)
          clockMode = openJpDaoRepo.CLOCK_MODE(from_address=from_address)
          print(clockMode)
          #　コントkラウトで実装されている
          #　まだblockが進んでいないのでは？
          #if proposalSnapshot == 0:
          #  return { "revort": "GovernorNonexistentProposal" }
            # revert GovernorNonexistentProposal(proposalId);

          proposalProposer = openJpDaoRepo.proposalProposer(proposalId=proposalId, from_address=from_address)
          state = openJpDaoRepo.state(proposalId=proposalId, from_address=from_address)
          return { "state": state, "proposal" : {"deadline": proposalDeadline, "snapshot": proposalSnapshot, "proposer": proposalProposer} }
        except Exception as e:
          # GovernorNonexistentProposalと判断する方法が必要。
          print(e)
          return  { "e": e }

        #　ここでコントらくと作成のじっけん
        #　ここで出力
        # time.sleep(10)  # 3秒間スリープ
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