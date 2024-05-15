# -*- coding: utf-8 -*-

import pytest
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.employee_authority_worker_nft import EmployeeAuthorityWorkerNFTRepogitory
from decentralized.utils.chains import Chains

#　ここはsetUP
hardhat_ethereum = Ethereum(url=Chains.HARDHAT_URL, chain_id=Chains.HARDHAT_CHAIN_ID)
nft = EmployeeAuthorityWorkerNFTRepogitory(ethereum=hardhat_ethereum)

# ここはgittHubActionの場合は、tempenvに書き込んで利用するべき。
owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
user_address_1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

class TestEmployeeAuthorityWorkerNFTRepogitory:

  @pytest.mark.skipif(not hardhat_ethereum.is_connected(), reason='no launch hardhat')
  def test_name(self):
    assert nft.name(from_address=owner) == "EmployeeAuthorityWorkerNFT"

  @pytest.mark.skipif(not hardhat_ethereum.is_connected(), reason='no launch hardhat')
  def test_symbol(self):
    assert nft.symbol(from_address=owner) == "EAWNFT"

  @pytest.mark.skipif(not hardhat_ethereum.is_connected(), reason='no launch hardhat')
  def test_mintNFT(self):
  	if nft.balanceOf(target_address=owner, from_address=owner) == 0:
  	  nft.mintNFT(address=owner, token_id=1, from_address=owner)
  	  assert  nft.balanceOf(target_address=owner, from_address=owner) == 1
