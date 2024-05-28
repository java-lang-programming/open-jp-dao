from fastapi import FastAPI
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.utils.chains import Chains
from decentralized.exceptions.invalid_chain_id import InvalidChainID
from decentralized.usecase.tokens import Tokens

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}

@app.get("/api/ethereum/{chain_id}/address/{address}/tokens")
def address_tokens(chain_id: str, address: str, q: str = None):
    # TODO check  chainID and address
    
    int_chain_id = 0
    try:
      int_chain_id = Chains.validate_chain_id(chain_id=chain_id)
    except Exception as e:
      return {"errors": [{"code": "aaaaa", "message": "chain_id error", "detail": repr(e)}]}

    # TODO addresss_check

    
    # chain_idからurlを取得する
    url = Chains.url_via_chain_id(chain_id=int_chain_id)


    ethereum = Ethereum(url=url, chain_id=int_chain_id)
    if not ethereum.is_connected():
      return {"errors": [{"code": "aaaaa", "message": "イーサリアムに接続できません。鯨飲とステータス画面へ", "detail": None}]}

    tokens = Tokens(ethereum=ethereum)
    #　エラーの場合はエラーを返す仕組みにする
    return tokens.execute(address=address)
