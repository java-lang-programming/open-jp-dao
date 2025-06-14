from fastapi import APIRouter

from src.bunsan.ethereum.ethereum import Ethereum
from src.bunsan.ethereum.chains import Chains


from src.decentralized.requests.verify import Verify

from src.decentralized.responses.errors import Errors, ErrorCodes

from src.exceptions.invalid_chain_exception import InvalidChainException
from src.exceptions.invalid_format_address_exception import (
    InvalidFormatAddressException,
)
from src.exceptions.not_connected_exception import NotConnectedException
from src.exceptions.siwe_message_verify_exception import SiweMessageVerifyException

from siwe import SiweMessage
import secrets
import string


router = APIRouter()


# curl http://localhost:8001/api/nonce
@router.get("/api/nonce", tags=["sessions"])
async def nonce():
    _ALPHANUMERICS = string.ascii_letters + string.digits
    return {"nonce": "".join(secrets.choice(_ALPHANUMERICS) for _ in range(20))}


@router.post("/api/verify", tags=["sessions"], status_code=201)
async def verify(verify: Verify):
    int_chain_id = 0
    try:
        int_chain_id = Chains.validate_chain_id(chain_id=verify.chain_id)
    except Exception as e:
        raise InvalidChainException(
            errors=Errors(
                code=ErrorCodes.INVALID_CHAIN_ID,
                message="chain_id error",
                detail=repr(e),
            ).to_dict()
        )

    ethereum = Ethereum(url=Chains.url_via_chain_id(chain_id=int_chain_id))
    if not ethereum.is_connected():
        raise NotConnectedException(
            errors=Errors(
                code=ErrorCodes.NOT_CONNECTED_ETHEREUM,
                message="イーサリアムに接続できませんでした",
                detail="接続先のステータスを確認してください",
            ).to_dict()
        )

    try:
        # Sign-In with Ethereumの実装(時間がある時に移植する)
        # https://eips.ethereum.org/EIPS/eip-4361
        message = SiweMessage.from_message(message=verify.message)
        message.verify(verify.signature, nonce=verify.nonce, domain=verify.domain)
    except Exception as e:
        raise SiweMessageVerifyException(
            errors=Errors(
                code=ErrorCodes.SIWE_MESSAGE_VERIFY_ERROR,
                message="SiweMessage verify error",
                detail=repr(e),
            ).to_dict()
        )


# データはない場合は{"ens_name":null}
# TODO open api
@router.get(
    "/api/ethereum/{chain_id}/address/{address}/ens", tags=["sessions"], status_code=200
)
async def ens_address(chain_id: str, address: str):
    int_chain_id = 0
    try:
        int_chain_id = Chains.validate_chain_id(chain_id=chain_id)
    except Exception as e:
        raise InvalidChainException(
            errors=Errors(
                code=ErrorCodes.INVALID_CHAIN_ID,
                message="chain_id error",
                detail=repr(e),
            ).to_dict()
        )

    ethereum = Ethereum(url=Chains.url_via_chain_id(chain_id=int_chain_id))
    if not ethereum.is_connected():
        raise NotConnectedException(
            errors=Errors(
                code=ErrorCodes.NOT_CONNECTED_ETHEREUM,
                message="イーサリアムに接続できませんでした",
                detail="接続先のステータスを確認してください",
            ).to_dict()
        )

    if not ethereum.is_checksum_address(address):
        raise InvalidFormatAddressException(
            errors=Errors(
                code=ErrorCodes.NOT_CONNECTED_ETHEREUM,
                message="イーサリアムのアドレスが不正です",
                detail="イーサリアムのアドレスを確認してください",
            ).to_dict()
        )

    ens_name = ethereum.ens_name(address=address)
    return {"ens_name": ens_name}
