#　色々と見直しをする

# https://web3py.readthedocs.io/en/stable/transactions.html
import json
from web3 import Web3

from bunsan.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.open_jp_dao_governor_repository import (
    OpenJpDaoGovernorRepository
)

# 可変
# 以下はhardhatを選択した場合
url = "http://host.docker.internal:8545"

#jsonStr = None
#with open(ABI_PATH, "r") as j:
#  jsonStr = json.load(j)

#abi = jsonStr['abi']
#print(abi)

# ethereum = Ethereum(url=url, chain_id=8545)
# print(ethereum.is_connected())
# targets = ["0x5FbDB2315678afecb367f032d93F642f64180aa3"]
# values = [0]
# call_data = ["0x"]
# description = "test"
# from_address = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

# openJpDaoRepo = OpenJpDaoGovernorRepository(ethereum=ethereum)
# receipt = openJpDaoRepo.propose(targets, values, call_data, description, from_address)
# print(receipt)

description = "test"

#　これはあっている　bytes(_message) strで返す
hex: str = Web3.to_hex(text=description)

print(hex)

result = Web3.keccak(hexstr=hex)
print(result)
print("result")
print(result.hex())

# 0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658
# 0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658

# aaa = Web3.keccak(text=str)

aaa = Web3.keccak(text='txt')


print(aaa)
print(aaa.hex())

bbb = aaa.hex()
print(bbb.__class__.__name__)
#print(hex.__class__.__name__)


# print(Web3.to_text(0x74657374))
# 0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658

#descriptionHash = Web3.to_bytes(Web3.keccak(text='txt'))
#print(descriptionHash)


#b = Web3.solidity_keccak(['bool'], [True])

#print(b.__class__.__name__)


#print(b.decode())

# # 繋がらなかったら、下には行かない

# # https://eips.ethereum.org/EIPS/eip-721
# nft = EmployeeAuthorityWorkerNFTRepogitory(ethereum=ethereum)

# owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
# user_address_1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
# user_address_2 = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
# user_address_3 = "0x90F79bf6EB2c4f870365E785982E1f101E93b906"


# print(nft.name(from_address=owner))
# print(nft.name(from_address=user_address_1))
# print(nft.name(from_address=user_address_2))
# print(nft.name(from_address=user_address_3))


# print(nft.symbol(from_address=owner))
# print(nft.symbol(from_address=user_address_1))
# print(nft.symbol(from_address=user_address_2))
# print(nft.symbol(from_address=user_address_3))


# print(nft.balanceOf(target_address=owner, from_address=owner))
# print(nft.balanceOf(target_address=user_address_1, from_address=owner))
# print(nft.balanceOf(target_address=user_address_1, from_address=user_address_2))
# # print(balance)
# print(nft.tokenURI(token_id=3, from_address=user_address_1))
