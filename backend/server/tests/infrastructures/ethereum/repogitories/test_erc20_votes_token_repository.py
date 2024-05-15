# -*- coding: utf-8 -*-

import pytest
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.erc20_votes_token_repository import ERC20VotesTokenRepository
from decentralized.utils.chains import Chains

#　ここはsetUP
hardhat_ethereum = Ethereum(url=Chains.HARDHAT_URL, chain_id=Chains.HARDHAT_CHAIN_ID)
vote_token = ERC20VotesTokenRepository(ethereum=hardhat_ethereum)

# ここはgittHubActionの場合は、tempenvに書き込んで利用するべき。
owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
user_address_1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

#　TODO 最後に値を元に戻すこと
class TestERC20VotesTokenRepository:

  @pytest.mark.skipif(not hardhat_ethereum.is_connected(), reason='no launch hardhat')
  def test_name(self):
    assert vote_token.name(from_address=owner) == "ERC20VotesToken"

  @pytest.mark.skipif(not hardhat_ethereum.is_connected(), reason='no launch hardhat')
  def test_symbol(self):
    assert vote_token.symbol(from_address=owner) == "EVT"

  # @pytest.mark.skipif(not hardhat_ethereum.is_connected(), reason='no launch hardhat')
  # def test_balanceOf(self):
  #   assert vote_token.balanceOf(target_address=owner, from_address=owner) == 0

  @pytest.mark.skipif(not hardhat_ethereum.is_connected(), reason='no launch hardhat')
  def test_mint(self):
  	if vote_token.balanceOf(target_address=owner, from_address=owner) == 0:
  	  vote_token.mint(target_address=owner, amount=ERC20VotesTokenRepository.FIRST_MINT_AMOUNT, from_address=owner)
  	  assert vote_token.balanceOf(target_address=owner, from_address=owner) == ERC20VotesTokenRepository.FIRST_MINT_AMOUNT

  @pytest.mark.skipif(not hardhat_ethereum.is_connected(), reason='no launch hardhat')
  def test_transfer(self):
    if vote_token.balanceOf(target_address=owner, from_address=owner) == ERC20VotesTokenRepository.FIRST_MINT_AMOUNT:
      vote_token.transfer(target_address=user_address_1, amount=ERC20VotesTokenRepository.FIRST_MINT_AMOUNT, from_address=owner)
      assert vote_token.balanceOf(target_address=owner, from_address=owner) == 0
      # assert vote_token.balanceOf(target_address=user_address_1, from_address=owner) == ERC20VotesTokenRepository.FIRST_MINT_AMOUNT
