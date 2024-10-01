from fastapi import APIRouter

from bunsan.ethereum.ethereum import Ethereum
from bunsan.ethereum.chains import Chains
from decentralized.usecase.votes.vote_add import VoteAdd
from decentralized.requests.votes.votes_add import VoteAddRequest
from decentralized.responses.errors import Errors, ErrorCodes

router = APIRouter()

# curl -X POST -H "Content-Type: application/json" -d '{"to": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "amount": 100 }' http://localhost:8001/api/ethereum/8545/address/0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266/addvote
# 投票用のトークンを付加する
@router.post("/api/ethereum/{chain_id}/address/{address}/addvote", tags=["votes"])
def vote_add(chain_id: str, address: str, voteAdd: VoteAddRequest):
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

    add = VoteAdd(ethereum=ethereum)
    try:
      add.execute(request=voteAdd, from_address=address)
    except Exception as e:
      return Errors(code=ErrorCodes.ERROR_VOTE_SHOW, message="vote show error", detail=repr(e)).to_dict()   

    return None