# -*- coding: utf-8 -*-
import pytest
import json
import os
from pathlib import Path
from unittest.mock import patch, mock_open
from src.decentralized.utils.contract_registry import (
   ContractRegistry
)

class TestContractRegistry:
    
    @pytest.fixture
    def registry(self):
        # テストごとにクリーンなインスタンスを生成
        # 環境変数をクリアした状態でテストしたい場合は、patchなどで制御します
        return ContractRegistry()

    ## --- get_address のテスト ---

    def test_get_address_success(self, registry):
        """デフォルト値または環境変数が正しく取得できるか"""
        # ハードコードされているデフォルト値の確認
        assert registry.get_address(31337, "JpycPayment") == "0x66aa579c43e387db178142Fcfc220fFC2b016145"
        assert registry.get_address(11155111, "JpycPayment") == "0x88ee579c43e387db178142Fcfc220fFC2b016145"

    def test_get_address_from_env(self):
        """環境変数が設定されている場合に優先されるか"""
        env_address = "0x9999999999999999999999999999999999999999"
        with patch.dict(os.environ, {"JPYC_PAYMENT_ADDRESS_POLYGON": env_address}):
            registry = ContractRegistry()
            assert registry.get_address(137, "JpycPayment") == env_address

    def test_get_address_fail(self, registry):
        """存在しないチェーンや名前で例外が出るか"""
        with pytest.raises(ValueError) as excinfo:
            registry.get_address(999, "UnknownContract")
        assert "Address not found" in str(excinfo.value)

    ## --- get_abi のテスト ---

    def test_get_abi_success_with_abi_key(self, registry):
        """Hardhat形式(JSON内に'abi'キーがある)の読み込みテスト"""
        mock_data = {"abi": [{"name": "test_func", "type": "function"}]}
        mock_json = json.dumps(mock_data)

        # ファイルオープンと存在確認をモック
        with patch("builtins.open", mock_open(read_data=mock_json)):
            with patch("os.path.exists", return_value=True):
                abi = registry.get_abi("JpycPayment")
                assert abi == mock_data["abi"]
                assert abi[0]["name"] == "test_func"

    def test_get_abi_success_plain_list(self, registry):
        """純粋なリスト形式のABI読み込みテスト"""
        mock_data = [{"name": "plain_func", "type": "function"}]
        mock_json = json.dumps(mock_data)

        with patch("builtins.open", mock_open(read_data=mock_json)):
            with patch("os.path.exists", return_value=True):
                abi = registry.get_abi("JpycPayment")
                assert abi == mock_data

    def test_get_abi_name_missing(self, registry):
        """ABI_NAMESに定義されていない名前を指定した場合"""
        with pytest.raises(ValueError) as excinfo:
            registry.get_abi("MissingABI")
        assert "name definition missing" in str(excinfo.value)

    def test_get_abi_file_not_found(self, registry):
        """ファイルが物理的に存在しない場合"""
        with patch("os.path.exists", return_value=False):
            with pytest.raises(FileNotFoundError):
                registry.get_abi("JpycPayment")

    def test_get_abi_real_file(self):
        registry = ContractRegistry()
        # 本物のファイルを開き、中身がリスト（ABI）であることを確認
        abi = registry.get_abi("JpycPayment")
        assert isinstance(abi, list)
        assert len(abi) > 0  # 中身が空じゃない

    ## --- パス計算の確認 ---

    def test_project_root_calculation(self, registry):
        """PROJECT_ROOT が Path オブジェクトであり、正しい階層を指しているか"""
        assert isinstance(registry.PROJECT_ROOT, Path)
        # 存在チェック
        assert registry.PROJECT_ROOT.exists()

        # 'src' や 'abi' フォルダが入っているか
        assert (registry.PROJECT_ROOT / "src").exists()
        assert (registry.PROJECT_ROOT / "abi").exists()
