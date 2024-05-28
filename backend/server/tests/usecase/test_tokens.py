# -*- coding: utf-8 -*-

import pytest
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.utils.chains import Chains
from decentralized.usecase.tokens import Tokens
from tests.utils.test_account import TestAccount


hardhat_ethereum = Ethereum(url=Chains.HARDHAT_URL, chain_id=Chains.HARDHAT_CHAIN_ID)
test_account = TestAccount()

class TestTokens:

  @pytest.mark.skipif(not hardhat_ethereum.is_connected(), reason='no launch hardhat')
  def test_execute(self):
    tokens = Tokens(ethereum=hardhat_ethereum)
    # {"tokens": [{"workerNft": {"balance": workerNftBalance, "mata_url": mata_url}}]}
    assert tokens.execute(address=test_account.owner_address) == {"tokens": [{"workerNft": {"balance": 1, "mata_url": "https://java-lang-programming.github.io/nfts/dwebnft/1"} }, {"votesToken":{"balance":0}}]}
