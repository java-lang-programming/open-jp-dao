from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.utils.chains import Chains
from decentralized.exceptions.invalid_chain_id import InvalidChainID
from decentralized.usecase.tokens import Tokens
from decentralized.usecase.nfts.create import Create
from decentralized.usecase.votes.vote_create import VoteCreate
from decentralized.usecase.votes.vote_show import VoteShow
from decentralized.responses.errors import Errors, ErrorCodes
from decentralized.requests.nft import Nft
from decentralized.requests.nonce import Nonce
from decentralized.requests.verify import Verify
from decentralized.requests.votes.votes_create import VoteCreateRequest
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

## ここからdao
#　仮実装
    # owner_address: str
    # token_address: str
    # call_data_type: int
    # title

# 投票を作成する
# curl -X POST -H "Content-Type: application/json" -d '{"description": "test", "token_address":"0x5FbDB2315678afecb367f032d93F642f64180aa3", "call_data_type": 1, "chain_id":8545, "from_address": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" }' http://localhost:8001/api/ethereum/8545/votes
@app.post("/api/ethereum/{chain_id}/votes")
async def vote_create(chain_id: str, voteCreate: VoteCreateRequest):
    int_chain_id = 0
    try:
      int_chain_id = Chains.validate_chain_id(chain_id=chain_id)
    except Exception as e: 
      return Errors(code=ErrorCodes.INVALID_CHAIN_ID, message="chain_id error", detail=repr(e)).to_dict()

    url = Chains.url_via_chain_id(chain_id=int_chain_id)

    ethereum = Ethereum(url=url, chain_id=int_chain_id)
    if not ethereum.is_connected():
      return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="イーサリアムに接続できませんでした", detail="接続先のステータスを確認してください").to_dict()

    create = VoteCreate(ethereum=ethereum)
    try:
      result = create.execute(voteCreate=voteCreate)
    except Exception as e:
      return Errors(code=ErrorCodes.ERROR_VOTE_CREATE, message="vote create error", detail=repr(e)).to_dict()

    return result

# curl -X GET -H "Content-Type: application/json" http://localhost:8001/api/ethereum/8545/address/0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266/votes/6575811453577265609264472254941757295222982262946132559213360139185348548097
# 投票を取得する
@app.get("/api/ethereum/{chain_id}/address/{address}/votes/{proposalId}")
def vote_show(chain_id: str, address: str, proposalId: str, q: str = None):
    #　ここが全部同じなので共通化
    int_chain_id = 0
    try:
      int_chain_id = Chains.validate_chain_id(chain_id=chain_id)
    except Exception as e: 
      return Errors(code=ErrorCodes.INVALID_CHAIN_ID, message="chain_id error", detail=repr(e)).to_dict()

    url = Chains.url_via_chain_id(chain_id=int_chain_id)

    ethereum = Ethereum(url=url, chain_id=int_chain_id)
    if not ethereum.is_connected():
      return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="イーサリアムに接続できませんでした", detail="接続先のステータスを確認してください").to_dict()

    show = VoteShow(ethereum=ethereum)
    try:
      rsult = show.execute(proposalId=int(proposalId), from_address=address)
    except Exception as e:
      return Errors(code=ErrorCodes.ERROR_VOTE_SHOW, message="vote show error", detail=repr(e)).to_dict()   

    return rsult



