import json
from web3 import Web3

from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.employee_authority_worker_nft import EmployeeAuthorityWorkerNFTRepogitory

# 可変
# 以下はhardhatを選択した場合
url = "http://host.docker.internal:8545"

ABI_PATH = "./abi/EmployeeAuthorityWorkerNFT.json"
# 実行するコントラクトのアドレス
contract_address = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"

#jsonStr = None
#with open(ABI_PATH, "r") as j:
#  jsonStr = json.load(j)

#abi = jsonStr['abi']
#print(abi)

ethereum = Ethereum(url=url, chain_id=8545)
print(ethereum.is_connected())

# 繋がらなかったら、下には行かない

# https://eips.ethereum.org/EIPS/eip-721
nft = EmployeeAuthorityWorkerNFTRepogitory(ethereum=ethereum)

owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
user_address_1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
user_address_2 = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
user_address_3 = "0x90F79bf6EB2c4f870365E785982E1f101E93b906"


print(nft.name(from_address=owner))
print(nft.name(from_address=user_address_1))
print(nft.name(from_address=user_address_2))
print(nft.name(from_address=user_address_3))


print(nft.symbol(from_address=owner))
print(nft.symbol(from_address=user_address_1))
print(nft.symbol(from_address=user_address_2))
print(nft.symbol(from_address=user_address_3))


print(nft.balanceOf(target_address=owner, from_address=owner))
print(nft.balanceOf(target_address=user_address_1, from_address=owner))
print(nft.balanceOf(target_address=user_address_1, from_address=user_address_2))
# print(balance)
print(nft.tokenURI(token_id=3, from_address=user_address_1))
# https://java-lang-programming.github.io/nfts/dwebnft/1
# print(nft.name(from=user_address_1))
# print(nft.name(from=user_address_2))
# print(nft.name(from=user_address_3))
# balance = nft.balanceOf(user_address_1)
# print(balance)
# if balance ==  0:
# 	print(nft.mintNFT(user_address_1, 3))
# balance = nft.balanceOf(user_address_1)
# print(balance)
#private_key = ""
