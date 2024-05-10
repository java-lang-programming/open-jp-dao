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

jsonStr = None
with open(ABI_PATH, "r") as j:
  jsonStr = json.load(j)

abi = jsonStr['abi']
print(abi)

ethereum = Ethereum(url=url, chain_id=8545)
print(ethereum.is_connected())

# 繋がらなかったら、下には行かない


nft = EmployeeAuthorityWorkerNFTRepogitory(ethereum=ethereum)

print(nft.name())
print(nft.symbol())
user_address_1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
print(nft.balanceOf(user_address_1))
