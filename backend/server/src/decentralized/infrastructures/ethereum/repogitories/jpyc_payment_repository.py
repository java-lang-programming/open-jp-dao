# -*- coding: utf-8 -*-

from src.bunsan.ethereum.ethereum import Ethereum
from src.decentralized.infrastructures.ethereum.repogitories.i_jpyc_payment_repository import (
    IJpycPaymentRepository,
)
from src.bunsan.ethereum.chains import Chains
from web3 import Web3


class JpycPaymentRepository(IJpycPaymentRepository):
    ARTIFACTS_JSON_PATH: str = "./abi/JpycPayment.json"
    HARDHAT_CONTRACT_ADDRESS: str = "0x66aa579c43e387db178142Fcfc220fFC2b016145"
    SEPOLIA_CONTRACT_ADDRESS: str = "0x88ee579c43e387db178142Fcfc220fFC2b016145"

    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum
        # 環境とコントラクトのログを出すこと
        ad = self.contract_address()
        ab = self.abi()
        self.contract = self.ethereum.contract(contract_address=ad, abi=ab)

    def abi(self):
        return self.ethereum.abi(json_path=JpycPaymentRepository.ARTIFACTS_JSON_PATH)

    # ネットワークに応じたコントラクトアドレスを返す
    def contract_address(self):
        if self.ethereum.chain_id == Chains.HARDHAT_CHAIN_ID:
            return JpycPaymentRepository.HARDHAT_CONTRACT_ADDRESS
        elif self.ethereum.chain_id == Chains.SEPOLIA_CHAIN_ID:
            return JpycPaymentRepository.SEPOLIA_CONTRACT_ADDRESS
        return None

    # 支払いの期間が有効かを確認する関数
    def isActive(self, user_address: str) -> bool:
        return self.contract.functions.isActive(
            Web3.to_checksum_address(user_address)
        ).call()

    # ユーザーの有効期限（Unixタイムスタンプ）を取得
    def getUserExpiry(self, user_address: str) -> int:
        return self.contract.functions.userExpiry(
            Web3.to_checksum_address(user_address)
        ).call()

    def getSubscriptionPaidLogs(
        self, from_block: int, to_block: str = "latest"
    ) -> list[dict]:
        # 1. イベントオブジェクトを直接取得（()をつけない、あるいは適切に参照する）
        event_api = self.contract.events.SubscriptionPaid

        # 2. 引数をスネークケース (from_block, to_block) に修正
        # Web3.py の高層APIではこちらが正解です
        try:
            event_logs = event_api().get_logs(from_block=from_block, to_block=to_block)
        except Exception as e:
            # RPCノードの制限（ブロック範囲が広すぎる等）でエラーが出る場合のハンドリング
            print(f"Error fetching logs: {e}")
            return []

        results = []
        for log in event_logs:
            # event_logs から取得したものは、すでに 'args' を持った状態でデコードされています
            results.append(
                {
                    "user": log.args.user,
                    "amount": log.args.amount,
                    "duration": log.args.duration,
                    "tx_hash": log["transactionHash"].hex(),
                    "block_number": log["blockNumber"],
                }
            )
        return results
