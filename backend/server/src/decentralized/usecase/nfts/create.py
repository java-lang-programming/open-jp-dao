# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.infrastructures.ethereum.repogitories.employee_authority_worker_nft import (
    EmployeeAuthorityWorkerNFTRepogitory,
)

from decentralized.requests.nft import Nft
from decentralized.exceptions.employee_authority_worker_nft_minted import (
    EmployeeAuthorityWorkerNFTMinted,
)
from decentralized.exceptions.invalid_employee_authority_nft import (
    InvalidEmployeeAuthorityNFT,
)


# historyでログを取得するAPIもあっていいな。
# https://ethereum.stackexchange.com/questions/134243/how-to-find-past-contract-events-with-web3py
class Create:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    def execute(self, nft: Nft):
        if nft.is_worker():
            worker_nft = EmployeeAuthorityWorkerNFTRepogitory(ethereum=self.ethereum)
            # nftの数
            worker_nft_balance: int = worker_nft.balanceOf(
                target_address=nft.targetAddress, from_address=nft.fromAddress
            )
            if worker_nft_balance > 0:
                # TODO log
                # class EmployeeAuthorityWorkerNFTFound
                raise EmployeeAuthorityWorkerNFTMinted(
                    "EmployeeAuthorityWorkerNFT is alredy minted."
                )

            # TODO eventを記録 ガス代の経費出力として記録日付は必須。
            worker_nft.mintNFT(address=nft.targetAddress, from_address=nft.fromAddress)
            # worker_nft.log_mint()
        else:
            # TODO log
            raise InvalidEmployeeAuthorityNFT(
                "意図しないNFTの種類がパラメーターで指定されています。"
            )

        return None
