# -*- coding: utf-8 -*-

from web3 import Web3
from decentralized.infrastructures.ethereum.repogitories.base_contract_repository import (
    BaseContractRepository,
)
from bunsan.ethereum.chains import Chains


class Ethereum(BaseContractRepository):
    def __init__(self, url: str, chain_id: int):
        self.w3 = Web3(Web3.HTTPProvider(url))
        self.chain_id = chain_id

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
    def get_transaction_receipt(self, tx_hash: any):
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

    # ネットワークを返す
    def network(self):
        if self.chain_id == Chains.HARDHAT_CHAIN_ID:
            return "localhost"
        elif self.chain_id == Chains.SEPOLIA_CHAIN_ID:
            return "sepolia"
        return None
