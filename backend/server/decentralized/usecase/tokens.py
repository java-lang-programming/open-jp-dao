# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.employee_authority_worker_nft import (
    EmployeeAuthorityWorkerNFTRepogitory,
)
from decentralized.infrastructures.ethereum.repogitories.erc20_votes_token_repository import (
    ERC20VotesTokenRepository,
)


class Tokens:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    def execute(self, address: str):
        worker_nft = EmployeeAuthorityWorkerNFTRepogitory(ethereum=self.ethereum)
        # nftの数
        worker_nft_balance: int = worker_nft.balanceOf(
            target_address=address, from_address=address
        )
        # TODO idを取得する必要がある
        mata_url: str = worker_nft.tokenURI(token_id=1, from_address=address)

        vote_token = ERC20VotesTokenRepository(ethereum=self.ethereum)
        vote_token_balance: int = vote_token.balanceOf(
            target_address=address, from_address=address
        )

        print("balance")
        print(worker_nft_balance)
        print("mata_url")
        print(mata_url)
        print("votebalance")
        print(vote_token_balance)
        # ここでmetaデータを取得する
        # holderとERC0token
        return {
            "tokens": [
                {"workerNft": {"balance": worker_nft_balance, "mata_url": mata_url}},
                {"votesToken": {"balance": vote_token_balance}},
            ]
        }
