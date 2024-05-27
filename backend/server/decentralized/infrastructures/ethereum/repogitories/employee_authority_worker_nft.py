# -*- coding: utf-8 -*-

from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.interfaces.i_erc721_metadata import (
    IERC721Metadata,
)
from decentralized.infrastructures.ethereum.repogitories.i_employee_authority_worker_nft import (
    IEmployeeAuthorityWorkerNFTRepogitory,
)


class EmployeeAuthorityWorkerNFTRepogitory(
    IERC721Metadata, IEmployeeAuthorityWorkerNFTRepogitory
):
    ARTIFACTS_JSON_PATH: str = "./abi/EmployeeAuthorityWorkerNFT.json"
    # 　同じコントラクトアドレスになるようにする
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

    def name(self, from_address: str) -> str:
        return self.contract.functions.name().call({"from": from_address})

    def symbol(self, from_address: str) -> str:
        return self.contract.functions.symbol().call({"from": from_address})

    def tokenURI(self, token_id: int, from_address: str) -> str:
        return self.contract.functions.tokenURI(token_id).call({"from": from_address})

    def balanceOf(self, target_address: str, from_address: str) -> None:
        return self.contract.functions.balanceOf(target_address).call(
            {"from": from_address}
        )

    def mintNFT(self, address: str, token_id: int, from_address: str):
        # from_addressも必要かも
        # 　トランザクション
        tx_hash = self.contract.functions.mintNFT(address, token_id).transact(
            {"from": from_address}
        )
        return self.ethereum.get_transaction_receipt(tx_hash)

    # def mint

    # https://web3py.readthedocs.io/en/stable/transactions.html
