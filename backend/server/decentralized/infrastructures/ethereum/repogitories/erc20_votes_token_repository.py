# -*- coding: utf-8 -*-

from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.interfaces.i_erc20_metadata import (
    IERC20Metadata,
)
from decentralized.infrastructures.ethereum.repogitories.interfaces.i_erc20 import (
    IERC20,
)

# from decentralized.infrastructures.ethereum.repogitories.i_employee_authority_worker_nft import (
#     IEmployeeAuthorityWorkerNFTRepogitory,
# )


# IERC721Metadata, IEmployeeAuthorityWorkerNFTRepogitory
class ERC20VotesTokenRepository(IERC20Metadata, IERC20):
    ARTIFACTS_JSON_PATH: str = "./abi/ERC20VotesToken.json"
    HARDHAT_CONTRACT_ADDRESS: str = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
    SEPOLIA_CONTRACT_ADDRESS: str = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"

    FIRST_MINT_AMOUNT: int = 1000000
    # 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9

    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum
        # 環境とコントラクトのログを出すこと
        ad = self.contract_address()
        ab = self.abi(json_path=ERC20VotesTokenRepository.ARTIFACTS_JSON_PATH)
        self.contract = self.ethereum.contract(contract_address=ad, abi=ab)

    # 　絶対に継承させるようにする
    def abi(self, json_path: str):
        return self.ethereum.abi(json_path=json_path)

    # 　ネットワークに応じたコントラクトアドレスを返す
    def contract_address(self):
        if self.ethereum.network() == "localhost":
            return ERC20VotesTokenRepository.HARDHAT_CONTRACT_ADDRESS
        elif self.ethereum.network() == "Sepolia":
            return ERC20VotesTokenRepository.SEPOLIA_CONTRACT_ADDRESS
        return None

    def name(self, from_address: str) -> str:
        return self.contract.functions.name().call({"from": from_address})

    def symbol(self, from_address: str) -> str:
        return self.contract.functions.symbol().call({"from": from_address})

    def balanceOf(self, target_address: str, from_address: str) -> int:
        return self.contract.functions.balanceOf(target_address).call(
            {"from": from_address}
        )

    def transfer(self, target_address: str, amount: int, from_address: str) -> bool:
        tx_hash = self.contract.functions.transfer(target_address, amount).transact(
            {"from": from_address}
        )
        return self.ethereum.get_transaction_receipt(tx_hash)

    def mint(self, target_address: str, amount: int, from_address: str):
        # from_addressも必要かも
        # 　トランザクション
        tx_hash = self.contract.functions.mint(target_address, amount).transact(
            {"from": from_address}
        )
        # receiptを返す
        # print(receipt)
        return self.ethereum.get_transaction_receipt(tx_hash)
        # myContract.events.myEvent().process_receipt(receipt)

    # https://web3py.readthedocs.io/en/stable/transactions.html
