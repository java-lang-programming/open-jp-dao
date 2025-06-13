# -*- coding: utf-8 -*-
import pytest
from src.bunsan.ethereum.chains import Chains
from src.bunsan.ethereum.exceptions.exception_invalid_chain_id import ExceptionInvalidChainID

class TestChains:

  def test_validate_chain_id(self):
    int_chain_id = Chains.validate_chain_id(chain_id="8545")
    assert int_chain_id == Chains.HARDHAT_CHAIN_ID

    int_chain_id = Chains.validate_chain_id(chain_id="11155111")
    assert int_chain_id == Chains.SEPOLIA_CHAIN_ID

    int_chain_id = Chains.validate_chain_id(chain_id="1")
    assert int_chain_id == Chains.MAIN_CHAIN_ID

    with pytest.raises(ExceptionInvalidChainID):
        Chains.validate_chain_id(chain_id="1111")

    with pytest.raises(ValueError):
        Chains.validate_chain_id(chain_id="aaaaa")

  def test_url_via_chain_id(self):
    url = Chains.url_via_chain_id(chain_id=Chains.HARDHAT_CHAIN_ID)
    assert url == Chains.HARDHAT_URL

    url = Chains.url_via_chain_id(chain_id=Chains.SEPOLIA_CHAIN_ID)
    assert url == Chains.SEPOLIA_URL

    url = Chains.url_via_chain_id(chain_id=Chains.MAIN_CHAIN_ID)
    assert url == Chains.MAIN_URL

    with pytest.raises(ExceptionInvalidChainID):
        Chains.url_via_chain_id(chain_id=2)
