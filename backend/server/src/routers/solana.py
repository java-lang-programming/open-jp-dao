from solathon.utils import verify_signature
from solathon.publickey import PublicKey
import base58
import logging

from solathon.utils import verify_signature
from solathon.publickey import PublicKey

from fastapi import APIRouter

from src.decentralized.requests.solana.verify import Verify

from src.decentralized.responses.errors import Errors, ErrorCodes

from src.exceptions.solana_verify_exception import SolanaVerifyException

router = APIRouter()
logger = logging.getLogger(__name__)


@router.post("/api/solana/verify", tags=["solana"])
async def verify(verify: Verify):
    try:

        result = verify_signature(
            public_key=PublicKey(verify.public_key),
            signature=base58.b58decode(verify.signature_b58),
            message=verify.message.encode("utf-8"),
        )
        if result is not None:
            raise ValueError("signature invalid")
    except Exception as e:
        logger.error(f"Solana verify failed: {e}", exc_info=True)
        raise SolanaVerifyException(
            errors=Errors(
                code=ErrorCodes.SOLANA_VERIFY_ERROR,
                message="solana verify error",
                detail=repr(e),
            ).to_dict()
        )

    return {"verified": True}
