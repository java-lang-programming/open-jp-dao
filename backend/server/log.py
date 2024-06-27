from fastapi import FastAPI
from pydantic import BaseModel
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.utils.chains import Chains
from decentralized.exceptions.invalid_chain_id import InvalidChainID
from decentralized.usecase.tokens import Tokens
from decentralized.usecase.nfts.create import Create
from decentralized.responses.errors import Errors, ErrorCodes
from decentralized.requests.nft import Nft

from decentralized.exceptions.employee_authority_worker_nft_minted import (
    EmployeeAuthorityWorkerNFTMinted,
)
from decentralized.exceptions.invalid_employee_authority_nft import (
    InvalidEmployeeAuthorityNFT,
)

chain_id = 8545
int_chain_id = 0
try:
  int_chain_id = Chains.validate_chain_id(chain_id=chain_id)
except Exception as e:
  print(e)

# TODO addresss_check 20バイト


# chain_idからurlを取得する
url = Chains.url_via_chain_id(chain_id=int_chain_id)

ethereum = Ethereum(url=url, chain_id=int_chain_id)