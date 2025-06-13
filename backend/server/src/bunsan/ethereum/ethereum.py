# -*- coding: utf-8 -*-

from web3 import Web3
from web3.types import TxReceipt
from src.bunsan.ethereum.repositories.base_contract_repository import (
    BaseContractRepository,
)


class Ethereum(BaseContractRepository):
    def __init__(self, url: str):
        self.w3 = Web3(provider=Web3.HTTPProvider(url))

    def is_connected(self) -> bool:
        return self.w3.is_connected()

    # 継承
    def abi(self, json_path: str):
        artifacts_json: any = super().load_artifacts_json(json_path=json_path)
        return artifacts_json["abi"]

    # コントラクトを返す
    def contract(self, contract_address: str, abi: any):
        return self.w3.eth.contract(address=contract_address, abi=abi)

    # トランザクじょんのreceipを取得する
    def get_transaction_receipt(self, tx_hash: any) -> TxReceipt:
        return self.w3.eth.get_transaction_receipt(tx_hash)

    def block_number(self):
        return self.w3.eth.block_number

    def is_checksum_address(self, user_address):
        return self.w3.is_checksum_address(user_address)

    # 残高
    def ether_balance(self, user_address: str):
        # return 0
        checksum_user_address = self.w3.to_checksum_address(user_address)
        return self.w3.from_wei(self.w3.eth.get_balance(checksum_user_address), "ether")
