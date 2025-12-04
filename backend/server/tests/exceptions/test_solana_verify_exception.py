# -*- coding: utf-8 -*-
from src.exceptions.solana_verify_exception import SolanaVerifyException

def test_solana_verify_exception_holds_errors():
    errors = {
        "errors": [
            {"code": 400, "message": "bad", "detail": "invalid"}
        ]
    }

    exc = SolanaVerifyException(errors)

    # エラー内容がそのまま保持されていることだけ確認すれば十分
    assert exc.errors == errors
    assert str(exc) == "Solana verification failed"
