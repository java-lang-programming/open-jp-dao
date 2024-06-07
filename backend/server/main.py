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


app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}

@app.get("/api/ethereum/{chain_id}/address/{address}/tokens")
def address_tokens(chain_id: str, address: str, q: str = None):
    int_chain_id = 0
    try:
      int_chain_id = Chains.validate_chain_id(chain_id=chain_id)
    except Exception as e:
      return Errors(code=ErrorCodes.INVALID_CHAIN_ID, message="chain_id error", detail=repr(e)).to_dict()

    # TODO addresss_check 20バイト

    
    # chain_idからurlを取得する
    url = Chains.url_via_chain_id(chain_id=int_chain_id)


    ethereum = Ethereum(url=url, chain_id=int_chain_id)
    if not ethereum.is_connected():
      return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="イーサリアムに接続できませんでした", detail="接続先のステータスを確認してください").to_dict()

    tokens = Tokens(ethereum=ethereum)
    #　エラーの場合はエラーを返す仕組みにする
    return tokens.execute(address=address)

# curl -X POST -H "Content-Type: application/json" -d '{"kind":1, "targetAddress":"0A396F4ce6aB8827279cffFb92266", "fromAddress": "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", "chainId":8545 }' http://localhost:8001/api/nfts
# curl -X POST -H "Content-Type: application/json" -d '{"kind":1, "address":"0xa1122334455667788990011223344556677889900"}' http://localhost:8001/api/nfts
@app.post("/api/nfts")
def create_nft(nft: Nft):
    print("aa")

    int_chain_id = 0
    try:
      int_chain_id = Chains.validate_chain_id(chain_id=nft.chainId)
    except Exception as e:
      return Errors(code=ErrorCodes.INVALID_CHAIN_ID, message="chain_id error", detail=repr(e)).to_dict()

    url = Chains.url_via_chain_id(chain_id=int_chain_id)


    ethereum = Ethereum(url=url, chain_id=int_chain_id)
    if not ethereum.is_connected():
      return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="イーサリアムに接続できませんでした", detail="接続先のステータスを確認してください").to_dict()

    create = Create(ethereum=ethereum)
    try:
        create.execute(nft=nft)
    except EmployeeAuthorityWorkerNFTMinted as e:
        return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="NFTはMINT済みです", detail=repr(e)).to_dict()
    except InvalidEmployeeAuthorityNFT as e:
        return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="不正なNFTが指定されました", detail=repr(e)).to_dict()
    except Exception as e:
        return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="予期せぬエラーが発生しました", detail=repr(e)).to_dict()

    return None
