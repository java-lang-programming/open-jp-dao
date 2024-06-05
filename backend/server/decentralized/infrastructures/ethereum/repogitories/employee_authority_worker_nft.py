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
        return self.contract.functions.tokenURI(token_id).call(
            {"from": from_address}
        )

    def balanceOf(self, target_address: str, from_address: str) -> int:
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

    def ownerOf(self, token_id: int, from_address: str) -> str:
        return self.contract.functions.ownerOf(token_id).call({"from": from_address})

    # 　複数所持は許可しないけど、一応
    # def tokenIDsOf(self, target_address: str, from_address: str) -> list[int]:
    #     token_ids: list[int] = []
    #     balance: int = self.balanceOf(
    #         target_address=target_address, from_address=from_address
    #     )
    #     if balance > 0:
    #         found_token_count: int = 0
    #         start_token_id: int = 0
    #         while found_token_count != balance:
    #             owner_address: str = self.ownerOf(
    #                 token_id=start_token_id, from_address=target_address
    #             )
    #             if owner_address == target_address:
    #                 token_ids.push(start_token_id)
    #                 found_token_count = found_token_count + 1
    #     return token_ids

    def tokenIDOf(self, target_address: str, from_address: str) -> int:
        balance: int = self.balanceOf(
          target_address=target_address, from_address=from_address
        )
        if balance != 1:
            # not found
            return -1

        not_found_token: bool = True
        start_token_id: int = 1
        # MAX 1000まで
        while not_found_token:
            owner_address: str = self.ownerOf(
                token_id=start_token_id, from_address=target_address
            )
            if owner_address == target_address:
                not_found_token = False
                return start_token_id
            start_token_id = start_token_id + 1
        # 件数over
        return -1
