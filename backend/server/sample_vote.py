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
tagret_address = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

ethereum = Ethereum(url=url, chain_id=8545)
print(ethereum.is_connected())


# 繋がらなかったら、下には行かない

# https://eips.ethereum.org/EIPS/eip-721
votes = ERC20VotesRepository(ethereum=ethereum)
print(votes.name(from_address=from_address))

# mint

# getVotes(self, tagret_address: str, from_address: str) -> int:
print(votes.getVotes(tagret_address=tagret_address, from_address=from_address))
# tagret_address: str, timepoint: int, from_address: str
print(votes.clock(from_address=from_address))
print(votes.getPastVotes(tagret_address=tagret_address, timepoint=0, from_address=from_address))

print(votes.mint(target_address=tagret_address, amount=1000, from_address=from_address))

# mint
print(votes.clock(from_address=from_address))

# transfer


# transfer

# ユーザーがvoteする



