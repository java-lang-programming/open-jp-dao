# -*- coding: utf-8 -*-
import os
from pathlib import Path
import json


class ContractRegistry:
    CURRENT_FILE_PATH = Path(__file__).resolve()
    PROJECT_ROOT = CURRENT_FILE_PATH.parent.parent.parent.parent

    # 2. プロジェクトルートにある abi フォルダを指定
    ABI_MASTER_DIR = PROJECT_ROOT / "abi"
    # ローカルのABIファイル名の定義（必要に応じて増やせるように辞書化）
    ABI_NAMES = {"JpycPayment": "JpycPayment.json"}

    def __init__(self):
        # 環境変数から各チェーンのアドレスを読み込む
        # keyの形式を "{name}_{chain_id}" に統一
        self._addresses: dict[str, str] = {
            "JpycPayment_137": os.getenv("JPYC_PAYMENT_ADDRESS_POLYGON"),
            "JpycPayment_1": os.getenv("JPYC_PAYMENT_ADDRESS_ETHEREUM"),
            "JpycPayment_11155111": os.getenv(
                "JPYC_PAYMENT_ADDRESS_SEPOLIA",
                "0x88ee579c43e387db178142Fcfc220fFC2b016145",
            ),
            "JpycPayment_31337": os.getenv(
                "JPYC_PAYMENT_ADDRESS_HARDHAT",
                "0x66aa579c43e387db178142Fcfc220fFC2b016145",
            ),
        }

    def _get_key(self, chain_id: int, name: str) -> str:
        """内部管理用のキーを生成"""
        return f"{name}_{chain_id}"

    def get_address(self, chain_id: int, name: str) -> str:
        """指定したチェーンのコントラクトアドレスを返す"""
        key = self._get_key(chain_id, name)
        address = self._addresses.get(key)

        if not address:
            raise ValueError(
                f"Address not found for {name} on chain {chain_id}. Check your .env file."
            )
        return address

    def get_abi(self, name: str) -> dict[str, any]:
        """
        指定したコントラクト名のABIを返す。
        """

        file_name = self.ABI_NAMES.get(name)
        if not file_name:
            # abi name not foundが良い
            raise ValueError(f"name definition missing for: {name}")

        abi_path = self.ABI_MASTER_DIR / f"{file_name}"
        if not os.path.exists(abi_path):
            # エラー
            raise FileNotFoundError(f"ABI file not found at: {abi_path}")

        with open(abi_path, "r", encoding="utf-8") as f:
            artifact = json.load(f)
            # Hardhat等の出力形式に合わせて "abi" キーの中身を取得
            abi = (
                artifact.get("abi")
                if isinstance(artifact, dict) and "abi" in artifact
                else artifact
            )
            return abi
