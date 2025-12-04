# -*- coding: utf-8 -*-

from src.decentralized.responses.errors import Errors

def test_to_dict_returns_error_dict():
    err = Errors(code=400, message="Bad Request", detail="Invalid parameter")

    result = err.to_dict()

    # 型チェック（TypedDict 構造）
    assert isinstance(result["code"], int)
    assert isinstance(result["message"], str)
    assert isinstance(result["detail"], str)

    # 値の検証
    assert result == {
        "code": 400,
        "message": "Bad Request",
        "detail": "Invalid parameter",
    }


def test_create_returns_errors_list():
    err = Errors(code=404, message="Not Found", detail="User not found")

    result = err.create()

    # Top-level key
    assert "errors" in result
    assert isinstance(result["errors"], list)
    assert len(result["errors"]) == 1

    error_item = result["errors"][0]

    # TypedDict 構造チェック
    assert error_item == {
        "code": 404,
        "message": "Not Found",
        "detail": "User not found",
    }
