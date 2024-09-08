#　色々と見直しをする

# https://web3py.readthedocs.io/en/stable/transactions.html
import json
from web3 import Web3

from bunsan.ethereum.ethereum import Ethereum
from bunsan.ethereum.repositories.erc20_votes_repository import (
    ERC20VotesRepository
)

# 可変
# 以下はhardhatを選択した場合
url = "http://host.docker.internal:8545"
from_address = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
tagret_address_1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
tagret_address_2 = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"

ethereum = Ethereum(url=url, chain_id=8545)
print(ethereum.is_connected())


# 繋がらなかったら、下には行かない

# https://eips.ethereum.org/EIPS/eip-721
votes = ERC20VotesRepository(ethereum=ethereum)

from_address_balance = votes.balanceOf(target_address=from_address, from_address=from_address)
tagret_address_1_balance = votes.balanceOf(target_address=tagret_address_1, from_address=from_address)

print(from_address_balance)
print(tagret_address_1_balance)

if from_address_balance == 0:
	votes.mint(target_address=from_address, amount=10000, from_address=from_address)

tagret_address_1_vote = votes.getVotes(tagret_address=tagret_address_1, from_address=tagret_address_1)

print(tagret_address_1_vote)


if tagret_address_1_vote == 0:
	# 投票分おくる
 	votes.transfer(to_address=tagret_address_1, amount=500, from_address=from_address)
 	votes.delegate(delegatee_address=tagret_address_1, from_address=tagret_address_1)
#  	logs = votes.eventTransfer().get_logs()
#  	print(logs)

tagret_address_2_vote = votes.getVotes(tagret_address=tagret_address_2, from_address=tagret_address_2)
print(tagret_address_2_vote)
if tagret_address_2_vote == 0:
	votes.setVote(to_address=tagret_address_2, amount=1000, from_address=from_address)



# print(votes.getVotes(tagret_address=from_address, from_address=from_address))
# print(votes.getVotes(tagret_address=tagret_address_1, from_address=from_address))
# print(votes.getVotes(tagret_address=tagret_address_1, from_address=from_address))

# mint(self, target_address: str, amount: int, from_address: str):
# vote.mint(target_address=from_address)


# delegatee
# _delegatee[tagret_address]; by from_address
#print(votes.delegates(tagret_address=tagret_address_2, from_address=tagret_address_1))
#print(votes.hasDelegates(tagret_address=tagret_address, from_address=from_address))

# voteがないとダメかも。処理をみてロジックをチェック　tagret_addressが異常者
#votes.delegate(delegatee_address=tagret_address_2, from_address=tagret_address_1)


#print(votes.delegates(tagret_address=tagret_address_2, from_address=tagret_address_1))
# print(votes.hasDelegates(tagret_address=tagret_address, from_address=from_address))

# mint

# getVotes(self, tagret_address: str, from_address: str) -> int:
# print(votes.getVotes(tagret_address=tagret_address, from_address=from_address))
# # tagret_address: str, timepoint: int, from_address: str
# print(votes.clock(from_address=from_address))
# print(votes.getPastVotes(tagret_address=tagret_address, timepoint=0, from_address=from_address))

# print(votes.mint(target_address=tagret_address, amount=1000, from_address=from_address))

# print(votes.getVotes(tagret_address=tagret_address, from_address=tagret_address))

# print(votes.clock(from_address=from_address))

# transfer


# transfer

# ユーザーがvoteする



