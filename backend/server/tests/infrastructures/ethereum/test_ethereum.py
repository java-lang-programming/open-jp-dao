# -*- coding: utf-8 -*-

from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.utils.chains import Chains

hardhat_ethereum = Ethereum(url=Chains.HARDHAT_URL, chain_id=Chains.HARDHAT_CHAIN_ID)

class TestEthereum:

  def test_network_hardhat(self):
    ethereum = Ethereum(url=Chains.HARDHAT_URL, chain_id=Chains.HARDHAT_CHAIN_ID)
    assert ethereum.network() == "localhost"

  def test_network_sepolia(self):
    ethereum = Ethereum(url=Chains.SEPOLIA_URL, chain_id=Chains.SEPOLIA_CHAIN_ID)
    assert ethereum.network() == "Sepolia"

  def test_is_connected_sepolia(self):
    ethereum = Ethereum(url=Chains.SEPOLIA_URL, chain_id=Chains.SEPOLIA_CHAIN_ID)
    assert ethereum.is_connected(), 'SEPOLIA_URL connected'
