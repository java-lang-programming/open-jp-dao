# -*- coding: utf-8 -*-

# import unittest
# from unittest.mock import patch, MagicMock # ANY もインポート

# from decentralized.infrastructures.ethereum.ethereum import Ethereum
# from decentralized.utils.chains import Chains

# hardhat_ethereum = Ethereum(url=Chains.HARDHAT_URL, chain_id=Chains.HARDHAT_CHAIN_ID)

# #　web3はisinstance() が使われているのでmockできないので、
# class TestEthereum(unittest.TestCase):

#   # --- __init__ メソッドのテスト ---
#   def test_init(self):
#     test_contract_address = "0xAbC1234567890aBcdEfgHijkLmnOpQrsTuvWxyz0123"
#     test_abi = [
#         {
#             "inputs": [],
#             "name": "getMessage",
#             "outputs": [{"internalType": "string", "name": "", "type": "string"}],
#             "stateMutability": "view",
#             "type": "function",
#         }
#     ]


#     with patch('web3.Web3') as mock_web3_class:
#       mock_web3 = MagicMock()
#       mock_web3.is_connected = MagicMock(return_value=True)
#       # mock_web3_class.is_connected = MagicMock(return_value=True)
#       # print(mock_web3_class)
#       # print("mock_web3.is_connected()")
#       # print(mock_web3.is_connected())
#       # print("mock_web3.is_connected() reult")
#       # # モックされた Web3 クラスがインスタンス化されたときに返すオブジェクトを設定
#       # # これが Ethereum.w3 に割り当てられる Mock オブジェクトになります
#       # #v
#       mock_web3_class = mock_web3

#       ethereum_instance = Ethereum(url=Chains.SEPOLIA_URL, chain_id=Chains.SEPOLIA_CHAIN_ID)

#       # # print("ethereum_instance.w3")
#       # print(ethereum_instance.w3)
#       # print(ethereum_instance.is_connected())
#       # self.assertIs(ethereum_instance.is_connected(), True)
#       #print(ethereum_instance.w3.eth)
#       #print(ethereum_instance.w3.eth.contract)

#       # 3. アサーション
#       # Web3 が正しい引数 (Web3.HTTPProvider(url) を含めて) でインスタンス化されたことを確認
#       # HTTPProvider の具体的なインスタンスをモックする必要がない場合は ANY を使えます。
#       # もし HTTPProvider もモックして、その引数を検証したい場合は、別途 patch が必要です。
#       # mock_web3_class.assert_called_once_with(ANY) # または Web3.HTTPProvider のモックを検証

#       # # w3 属性がモックされたインスタンスであることを確認
#       # self.assertIs(ethereum_instance.w3, mock_web3_instance)
#       # # chain_id 属性が正しく設定されたことを確認
#       # self.assertEqual(ethereum_instance.chain_id, Chains.SEPOLIA_CHAIN_ID)

#   # def test_is_connected(self):
#   #   with patch('decentralized.infrastructures.ethereum.ethereum.Web3.is_connected', new_callable=Mock) as mock_web3_class:
#   #     mock_web3_class.is_connected.return_value = True
#   #     ethereum_instance = Ethereum(url=Chains.SEPOLIA_URL, chain_id=Chains.SEPOLIA_CHAIN_ID)
#   #     self.assertTrue(ethereum_instance.is_connected())

#   # def test_contract(self):
#   #   with patch('decentralized.infrastructures.ethereum.ethereum.Web3.is_connected', new_callable=Mock) as mock_web3_class:
#   # def test_network_hardhat(self):
#   #   ethereum = Ethereum(url=Chains.HARDHAT_URL, chain_id=Chains.HARDHAT_CHAIN_ID)
#   #   assert ethereum.network() == "localhost"

#   # def test_network_sepolia(self):
#   #   ethereum = Ethereum(url=Chains.SEPOLIA_URL, chain_id=Chains.SEPOLIA_CHAIN_ID)
#   #   assert ethereum.network() == "Sepolia"

#   # def test_is_connected_sepolia(self):
#   #   ethereum = Ethereum(url=Chains.SEPOLIA_URL, chain_id=Chains.SEPOLIA_CHAIN_ID)
#   #   assert ethereum.is_connected(), 'SEPOLIA_URL connected'
