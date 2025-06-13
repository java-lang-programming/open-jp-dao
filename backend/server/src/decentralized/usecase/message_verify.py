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
        worker_nft_repo = EmployeeAuthorityWorkerNFTRepogitory(ethereum=self.ethereum)

        token_id: int = worker_nft_repo.tokenIDOf(
            target_address=address, from_address=address
        )
        worker_nft: dict | None = None
        if token_id != -1:
            meta_url: str = worker_nft_repo.tokenURI(
                token_id=token_id, from_address=address
            )
            worker_nft = {"token_id": token_id, "meta_url": meta_url}

        worker_nft_repo.log_mint()

        vote_token = ERC20VotesTokenRepository(ethereum=self.ethereum)
        vote_token_balance: int = vote_token.balanceOf(
            target_address=address, from_address=address
        )

        return {
            "tokens": [
                {"workerNft": worker_nft},
                {"votesToken": {"balance": vote_token_balance}},
            ]
        }
