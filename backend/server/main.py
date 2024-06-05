from fastapi import FastAPI
from pydantic import BaseModel
from decentralized.infrastructures.ethereum.ethereum import Ethereum
from decentralized.utils.chains import Chains
from decentralized.exceptions.invalid_chain_id import InvalidChainID
from decentralized.usecase.tokens import Tokens
from decentralized.responses.errors import Errors, ErrorCodes


app = FastAPI()


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

class Nft(BaseModel):
    kind: int
    address: str
    chainId: int

    # ethereum/{chain_id}/address/{address}

    # def create(self, engagement_targets_job_categories: any):
    def is_worker(self):
        if self.kind == 1:
            print("workerだよ")

# ccurl -X POST -H "Content-Type: application/json" -d '{"name":"太郎", "age":"30"}' https://xxxxx.net/xxxxxx
# curl -X POST -H "Content-Type: application/json" -d '{"kind":1, "address":"0xa1122334455667788990011223344556677889900"}' http://localhost:8001/api/nfts
@app.post("/api/nfts")
# async def create_nft(nft: Nft):
def create_nft(nft: Nft):
    print("qqqqq")
    # nftの種類をチェック
    print(nft.is_worker())

    int_chain_id = 0
    try:
      int_chain_id = Chains.validate_chain_id(chain_id=nft.chainId)
    except Exception as e:
      return Errors(code=ErrorCodes.INVALID_CHAIN_ID, message="chain_id error", detail=repr(e)).to_dict()

    url = Chains.url_via_chain_id(chain_id=int_chain_id)


    ethereum = Ethereum(url=url, chain_id=int_chain_id)
    if not ethereum.is_connected():
      return Errors(code=ErrorCodes.NOT_CONNECTED_ETHEREUM, message="イーサリアムに接続できませんでした", detail="接続先のステータスを確認してください").to_dict()

    
    # 接続チェック
    #print(nft.IsWorker())

    return {"aa": "ok"}




# #　ユーザー情報
# def user():
#     # select * from users
#     # addressからnftを取得
#     # 