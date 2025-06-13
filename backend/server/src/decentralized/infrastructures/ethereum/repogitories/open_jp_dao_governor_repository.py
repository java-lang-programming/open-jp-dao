# -*- coding: utf-8 -*-

from web3 import Web3
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from bunsan.ethereum.repositories.i_governor_repository import (
    IGovernorRepository,
)
from bunsan.ethereum.eips.i_erc6372 import (
    IERC6372,
)

# from decentralized.infrastructures.ethereum.repogitories.interfaces.i_erc20 import (
#     IERC20,
# )

# from decentralized.infrastructures.ethereum.repogitories.i_employee_authority_worker_nft import (
#     IEmployeeAuthorityWorkerNFTRepogitory,
# )


# IERC721Metadata, IEmployeeAuthorityWorkerNFTRepogitory
class OpenJpDaoGovernorRepository(IGovernorRepository, IERC6372):
    ARTIFACTS_JSON_PATH: str = "./abi/OpenJpDaoGovernor.json"
    HARDHAT_CONTRACT_ADDRESS: str = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
    SEPOLIA_CONTRACT_ADDRESS: str = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"

    FIRST_MINT_AMOUNT: int = 1000000
    # 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9

    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum
        # 環境とコントラクトのログを出すこと
        ad = self.contract_address()
        ab = self.abi(json_path=OpenJpDaoGovernorRepository.ARTIFACTS_JSON_PATH)
        self.contract = self.ethereum.contract(contract_address=ad, abi=ab)

    # 　絶対に継承させるようにする
    def abi(self, json_path: str):
        return self.ethereum.abi(json_path=json_path)

    # 　ネットワークに応じたコントラクトアドレスを返す
    def contract_address(self):
        if self.ethereum.network() == "localhost":
            return OpenJpDaoGovernorRepository.HARDHAT_CONTRACT_ADDRESS
        elif self.ethereum.network() == "Sepolia":
            return OpenJpDaoGovernorRepository.SEPOLIA_CONTRACT_ADDRESS
        return None

    def hasVoted(self, proposalId: int, target_address: str, from_address: str) -> bool:
        return self.contract.functions.hasVoted(proposalId, target_address).call(
            {"from": from_address}
        )

    def propose(
        self,
        targets: list[str],
        values: list[int],
        calldatas: str,
        description: str,
        from_address: str,
    ):
        tx_hash = self.contract.functions.propose(
            targets, values, calldatas, description
        ).transact({"from": from_address})
        # TODO eventをlocalにDBに保存する。保存の有無はフラグで判断可能にする
        receipt = self.ethereum.get_transaction_receipt(tx_hash)

        print("receipt")
        print(receipt)

        # 　分割する　かつ　classにする ２回目はどうなる？
        logs = self.proposalCreatedEventLogs()
        event = logs[0]
        print("event.args")
        print(event)
        return event.args.proposalId

        # return self.contract.functions.propose(targets, values, calldatas, description).call({"from": from_address})

    def proposalDeadline(self, proposalId: int, from_address: str) -> int:
        return self.contract.functions.proposalDeadline(proposalId).call(
            {"from": from_address}
        )

    # https://zenn.dev/markwu/scraps/f7a17153baeb08
    def proposalSnapshot(self, proposalId: int, from_address: str) -> int:
        return self.contract.functions.proposalSnapshot(proposalId).call(
            {"from": from_address}
        )

    def proposalProposer(self, proposalId: int, from_address: str) -> str:
        return self.contract.functions.proposalProposer(proposalId).call(
            {"from": from_address}
        )

    # bytes32 descriptionHash pythonでも同暗号化処理が必要
    def hashProposal(
        self,
        targets: list[str],
        values: list[int],
        calldatas: str,
        description: str,
        from_address: str,
    ) -> int:
        description_hash = Web3.keccak(hexstr=Web3.to_hex(text=description))
        return self.contract.functions.hashProposal(
            targets, values, calldatas, description_hash
        ).call({"from": from_address})

    def castVote(self, proposalId: int, support: int, from_address: str) -> int:
        tx_hash = self.contract.functions.castVote(proposalId, support).transact(
            {"from": from_address}
        )

        receipt = self.ethereum.get_transaction_receipt(tx_hash)

        print("receipt")
        print(receipt)
        logs = self.contract.events.VoteCast.get_logs()
        event = logs[0]
        print("event.args")
        print(event)

        return 1

    def state(self, proposalId: int, from_address: str) -> int:
        return self.contract.functions.state(proposalId).call({"from": from_address})

    def clock(self, from_address: str) -> int:
        return self.contract.functions.clock().call({"from": from_address})

    def CLOCK_MODE(self, from_address: str) -> int:
        return self.contract.functions.CLOCK_MODE().call({"from": from_address})

    def proposalCreatedEventLogs(self):
        return self.contract.events.ProposalCreated.get_logs()
