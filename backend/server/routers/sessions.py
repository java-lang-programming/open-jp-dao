from fastapi import APIRouter

from bunsan.ethereum.ethereum import Ethereum
from bunsan.ethereum.chains import Chains

from decentralized.requests.verify import Verify

from decentralized.responses.errors import Errors, ErrorCodes

from siwe import SiweMessage
import secrets
import string

router = APIRouter()


# curl http://localhost:8001/api/nonce
@router.get("/api/nonce", tags=["sessions"])
async def nonce():
    _ALPHANUMERICS = string.ascii_letters + string.digits
    return {"nonce": "".join(secrets.choice(_ALPHANUMERICS) for _ in range(20))}

@router.post("/api/verify", tags=["sessions"])
async def verify(verify: Verify):
    int_chain_id = 0
    try:
      int_chain_id = Chains.validate_chain_id(chain_id=verify.chain_id)
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

