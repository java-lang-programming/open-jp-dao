from fastapi import APIRouter

from bunsan.ethereum.ethereum import Ethereum
from bunsan.ethereum.chains import Chains
from decentralized.usecase.votes.vote_create import VoteCreate
from decentralized.responses.errors import Errors, ErrorCodes

router = APIRouter()


# jpycで支払う
# curl -X POST -H "Content-Type: application/json" -d '{"description": "test", "token_address":"0x5FbDB2315678afecb367f032d93F642f64180aa3", "call_data_type": 1, "chain_id":8545, "from_address": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" }' http://localhost:8001/api/ethereum/8545/votes
@router.post("/api/jpyc/payment", tags=["jpyc"])
async def create_jpyc_payment(payment_data: JPYCPaymentRequest):
    int_chain_id = 0
    try:
        int_chain_id = Chains.validate_chain_id(chain_id=chain_id)
    except Exception as e:
        return Errors(
            code=ErrorCodes.INVALID_CHAIN_ID, message="chain_id error", detail=repr(e)
        ).to_dict()

    url = Chains.url_via_chain_id(chain_id=int_chain_id)

    ethereum = Ethereum(url=url, chain_id=int_chain_id)
    if not ethereum.is_connected():
        return Errors(
            code=ErrorCodes.NOT_CONNECTED_ETHEREUM,
            message="イーサリアムに接続できませんでした",
            detail="接続先のステータスを確認してください",
        ).to_dict()

    # 　ここで処理
    create = VoteCreate(ethereum=ethereum)
    try:
        result = create.execute(voteCreate=voteCreate)
    except Exception as e:
        return Errors(
            code=ErrorCodes.ERROR_VOTE_CREATE,
            message="vote create error",
            detail=repr(e),
        ).to_dict()

    return result
