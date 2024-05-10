# -*- coding: utf-8 -*-

from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.i_employee_authority_worker_nft import (
    IEmployeeAuthorityWorkerNFTRepogitory,
)


class EmployeeAuthorityWorkerNFTRepogitory(IEmployeeAuthorityWorkerNFTRepogitory):
    ARTIFACTS_JSON_PATH: str = "./abi/EmployeeAuthorityWorkerNFT.json"
    HARDHAT_CONTRACT_ADDRESS: str = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"

    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum
        # 環境とコントラクトのログを出すこと
        ad = self.contract_address()
        ab = self.abi(
            json_path=EmployeeAuthorityWorkerNFTRepogitory.ARTIFACTS_JSON_PATH
        )
        self.contract = self.ethereum.contract(contract_address=ad, abi=ab)

    # 　絶対に継承させるようにする
    def abi(self, json_path: str):
        return self.ethereum.abi(json_path=json_path)

    # 　ネットワークに応じたコントラクトアドレスを返す
    def contract_address(self):
        if self.ethereum.network() == "localhost":
            return EmployeeAuthorityWorkerNFTRepogitory.HARDHAT_CONTRACT_ADDRESS
        return None

    # 　継承
    def name(self):
        return self.contract.functions.name().call()

    def symbol(self) -> None:
        return self.contract.functions.symbol().call()

    def balanceOf(self, address: str) -> None:
        return self.contract.functions.balanceOf(address).call()

    # def mint

    # https://web3py.readthedocs.io/en/stable/transactions.html
