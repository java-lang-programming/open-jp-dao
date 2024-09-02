# -*- coding: utf-8 -*-
from bunsan.ethereum.exceptions.exception_invalid_chain_id import ExceptionInvalidChainID

class Chains:
    # これは環境によって変わるので可変に
    HARDHAT_URL: str = "http://host.docker.internal:8545"
    HARDHAT_CHAIN_ID: int = 8545
    HARDHAT_CHAIN_NAME: str = "localhost"
    SEPOLIA_URL: str = "https://rpc.sepolia.org"
    SEPOLIA_CHAIN_ID: int = 11155111
    SEPOLIA_CHAIN_NAME: int = "sepolia"

    @staticmethod
    def validate_chain_id(chain_id: str) -> int:
        """
        chain_idが有効であるか判断
        """
        int_chain_id: int = int(chain_id)

        match int_chain_id:
            case Chains.HARDHAT_CHAIN_ID:
                return Chains.HARDHAT_CHAIN_ID
            case Chains.SEPOLIA_CHAIN_ID:
                return Chains.SEPOLIA_CHAIN_ID
            case _:
                raise ExceptionInvalidChainID(
                    "invalid chain id. chain id must be {} or {}".format(
                        Chains.HARDHAT_CHAIN_ID, Chains.SEPOLIA_CHAIN_ID
                    )
                )

    def url_via_chain_id(chain_id: int) -> str:
        """
        chain_idからurlを取得
        """
        match chain_id:
            case Chains.HARDHAT_CHAIN_ID:
                return Chains.HARDHAT_URL
            case Chains.SEPOLIA_CHAIN_ID:
                return Chains.SEPOLIA_URL
            case _:
                raise ExceptionInvalidChainID(
                    "invalid chain id. chain id must be {} or {}".format(
                        Chains.HARDHAT_CHAIN_ID, Chains.SEPOLIA_CHAIN_ID
                    )
                )