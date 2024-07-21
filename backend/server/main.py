from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.utils.chains import Chains
from decentralized.exceptions.invalid_chain_id import InvalidChainID
from decentralized.usecase.tokens import Tokens
from decentralized.usecase.nfts.create import Create
from decentralized.responses.errors import Errors, ErrorCodes
from decentralized.requests.nft import Nft
from decentralized.requests.nonce import Nonce
from decentralized.requests.verify import Verify
import secrets
import string
from siwe import SiweMessage

from decentralized.exceptions.employee_authority_worker_nft_minted import (
    EmployeeAuthorityWorkerNFTMinted,
)
from decentralized.exceptions.invalid_employee_authority_nft import (
    InvalidEmployeeAuthorityNFT,
)


app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:3010",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

# token発行

# curl -X POST -H "Content-Type: application/json" -d '{"kind":1, "targetAddress":"0A396F4ce6aB8827279cffFb92266", "fromAddress": "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", "chainId":8545 }' http://localhost:8001/api/nfts
# curl -X POST -H "Content-Type: application/json" -d '{"kind":1, "address":"0xa1122334455667788990011223344556677889900"}' http://localhost:8001/api/nfts
@app.post("/api/nfts")
def create_nft(nft: Nft):
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

#　イーサリアムの情報を取得
@app.get("/api/ethereum/{chain_id}/address/{address}")
def ethereum_balance(chain_id: str, address: str, q: str = None):
    # ethrim, e := network.validate(chainId, )
    # https://note.com/yutakikuchi/n/nfad48f121cab
    int_chain_id = 0
    try:
      int_chain_id = Chains.validate_chain_id(chain_id=chain_id)
    except Exception as e:
      return Errors(code=ErrorCodes.INVALID_CHAIN_ID, message="chain_id error", detail=repr(e)).to_dict()

    url = Chains.url_via_chain_id(chain_id=int_chain_id)

    ethereum = Ethereum(url=url, chain_id=int_chain_id)
    if not ethereum.is_connected():
      return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="イーサリアムに接続できませんでした", detail="接続先のステータスを確認してください").to_dict()

    balance = ethereum.ether_balance(user_address=address)
    return {"balance": balance}

# curl -X POST -H "Content-Type: application/json" -d '{"address":"0A396F4ce6aB8827279cffFb92266", "chainId":8545 }' http://localhost:8001/api/nonce
@app.get("/api/nonce")
def nonce():
    _ALPHANUMERICS = string.ascii_letters + string.digits
    return {"nonce": "".join(secrets.choice(_ALPHANUMERICS) for _ in range(20))}

# https://github.com/spruceid/siwe-quickstart/blob/main/03_complete_app/backend/src/index.js
# https://github.com/spruceid/siwe-py
# message=eip_4361_string)
# prams { message, stirng, signature: string, nonce: String, domain= string }
# message.verify(signature, nonce="abcdef", domain="example.com"
# session https://blog.hapins.net/entry/2023/03/05/113755
@app.post("/api/verify")
async def verify(verify: Verify):
    int_chain_id = 0
    try:
      int_chain_id = Chains.validate_chain_id(chain_id=verify.chain_id)
      print(int_chain_id)
    except Exception as e:
      print("ここ")  
      return Errors(code=ErrorCodes.INVALID_CHAIN_ID, message="chain_id error", detail=repr(e)).to_dict()

    url = Chains.url_via_chain_id(chain_id=int_chain_id)

    print(url)

    ethereum = Ethereum(url=url, chain_id=int_chain_id)
    if not ethereum.is_connected():
      return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="イーサリアムに接続できませんでした", detail="接続先のステータスを確認してください").to_dict()

    try:
        message = SiweMessage.from_message(message=verify.message)
        print(message)
        aaa = message.verify(verify.signature, nonce=verify.nonce, domain=verify.domain)
        print(aaa)
        #print("エラーe")message = SiweMessage(message=verify.message)
    except Exception as e:
        print("エラーe")
        return Errors(code=ErrorCodes.INVALID_CHAIN_ID, message="chain_id error", detail=repr(e)).to_dict()

    # expiration_timeは1hってとこかな
    return {"status": "OK", "expiration_time": "aaaa"}

    # print(message.expiration_time)
    # チェック
    # try:
    #     message = SiweMessage(message=verify.message)
    #     print("calling2")
    #     # print("message.expiration_time")
    #     # print(message.expiration_time)
    #     # expiration_timeが取れる
    #     message.verify(verify.signature, nonce=verify.nonce, domain=verify.domain)
    #     print("calling3")
    #     print(message.expiration_time)
    # except siwe.ValueError:
    #     # Invalid message
    #     print("Authentication attempt rejected.")
    # except siwe.ExpiredMessage:
    #     print("Authentication attempt rejected.")
    # except siwe.DomainMismatch:
    #     print("Authentication attempt rejected.")
    # except siwe.NonceMismatch:
    #     print("Authentication attempt rejected.")
    # except siwe.MalformedSession as e:
    #     # e.missing_fields contains the missing information needed for validation
    #     print("Authentication attempt rejected.")
    # except siwe.InvalidSignature:
    #     print("Authentication attempt rejected.")
    
    #　ここでsession
#　次 
#　かかった費用とか。
