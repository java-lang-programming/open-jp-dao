# -*- coding: utf-8 -*-

from bunsan.ethereum.ethereum import Ethereum
from bunsan.ethereum.eips.i_erc20_metadata import (
    IERC20Metadata,
)
from bunsan.ethereum.eips.i_erc20 import (
    IERC20,
)
from bunsan.ethereum.eips.i_erc5805 import (
    IERC5805,
)

from bunsan.ethereum.eips.i_erc6372 import (
    IERC6372,
)

from bunsan.ethereum.chains import Chains


class ERC20VotesRepository(IERC20Metadata, IERC20, IERC5805, IERC6372):
    ARTIFACTS_JSON_PATH: str = "./abi/ERC20VotesToken.json"
    HARDHAT_CONTRACT_ADDRESS: str = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
    SEPOLIA_CONTRACT_ADDRESS: str = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"

    FIRST_MINT_AMOUNT: int = 1000000

    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum
        # 環境とコントラクトのログを出すこと
        ad = self.contract_address()
        ab = self.abi(json_path=ERC20VotesRepository.ARTIFACTS_JSON_PATH)
        self.contract = self.ethereum.contract(contract_address=ad, abi=ab)

    # 　絶対に継承させるようにする
    def abi(self, json_path: str):
        return self.ethereum.abi(json_path=json_path)

    # 　ネットワークに応じたコントラクトアドレスを返す
    def contract_address(self):
        if self.ethereum.network() == Chains.HARDHAT_CHAIN_NAME:
            return ERC20VotesRepository.HARDHAT_CONTRACT_ADDRESS
        elif self.ethereum.network() == Chains.SEPOLIA_CHAIN_NAME:
            return ERC20VotesRepository.SEPOLIA_CONTRACT_ADDRESS
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
        return self.ethereum.wait_for_transaction_receipt(tx_hash)

    def clock(self, from_address: str) -> int:
        return self.contract.functions.clock().call(
            {"from": from_address}
        )

    def CLOCK_MODE(from_address: str) -> str:
        return self.contract.functions.CLOCK_MODE().call(
            {"from": from_address}
        )

    def getVotes(self, tagret_address: str, from_address: str) -> int:
        return self.contract.functions.getVotes(tagret_address).call(
            {"from": from_address}
        )

    def getPastVotes(self, tagret_address: str, timepoint: int, from_address: str) -> str:
        return self.contract.functions.getPastVotes(tagret_address, timepoint).call(
            {"from": from_address}
        )

    def delegates(self, tagret_address: str, timepoint: int, from_address: str) -> str:
        return self.contract.functions.delegates(tagret_address, timepoint).call(
            {"from": from_address}
        )
