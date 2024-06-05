# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum


class Create:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    def execute(self, address: str):
        return {}
        # worker_nft = EmployeeAuthorityWorkerNFTRepogitory(ethereum=self.ethereum)
        # # nftの数
        # worker_nft_balance: int = worker_nft.balanceOf(
        #     target_address=address, from_address=address
        # )

        # #　workderのnftを持っているなら探す
        # # 数が増えると時間がかかるのでチェーン上のcacheに格納しておく。
        # #　これはリポジトリ or usecase案件
        # token_ids = []
        # if worker_nft_balance > 0:
        #     token_ids = []
        #     found_token = 0
        #     start_token_id = 0
        #     while found_token != worker_nft_balance:
        #          # tokenのowneを取得
        #        owner_address: str = worker_nft.ownerOf(tokenId=start_token_id, from_address=address)
        #        if owner_address == address:
        #             token_ids.push(start_token_id)
        #             found_token = found_token + 1

        # if token_ids > 0
        #   range(len(token_ids)):
        #       meta_url: str = worker_nft.tokenURI(token_id=1, from_address=address)

        # vote_token = ERC20VotesTokenRepository(ethereum=self.ethereum)
        # vote_token_balance: int = vote_token.balanceOf(
        #     target_address=address, from_address=address
        # )

        # print("balance")
        # print(worker_nft_balance)
        # print("mata_url")
        # print(mata_url)
        # print("votebalance")
        # print(vote_token_balance)
        # # ここでmetaデータを取得する
        # # holderとERC0token
        # return {
        #     "tokens": [
        #         {"workerNft": ["token_id": 1, "meta_url": meta_url]},
        #         {"votesToken": {"balance": vote_token_balance}},
        #     ]
        # }
