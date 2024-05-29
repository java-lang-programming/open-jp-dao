# -*- coding: utf-8 -*-
import pytest
from decentralized.utils.chains import Chains
from decentralized.exceptions.invalid_chain_id import InvalidChainID

class TestChains:

  def test_validate_chain_id(self):
    int_chain_id = Chains.validate_chain_id(chain_id="8545")
    assert int_chain_id == Chains.HARDHAT_CHAIN_ID

    int_chain_id = Chains.validate_chain_id(chain_id="11155111")
    assert int_chain_id == Chains.SEPOLIA_CHAIN_ID

    with pytest.raises(InvalidChainID):
        Chains.validate_chain_id(chain_id="1111")

    with pytest.raises(ValueError):
        Chains.validate_chain_id(chain_id="aaaaa")

  def test_url_via_chain_id(self):
    url = Chains.url_via_chain_id(chain_id=Chains.HARDHAT_CHAIN_ID)
    assert url == Chains.HARDHAT_URL

    url = Chains.url_via_chain_id(chain_id=Chains.SEPOLIA_CHAIN_ID)
    assert url == Chains.SEPOLIA_URL

    with pytest.raises(InvalidChainID):
        Chains.url_via_chain_id(chain_id=1)
