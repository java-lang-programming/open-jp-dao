## backend

0pen JP Daoで利用するpythonコード

## コンテナに入る

```
docker exec -it open-jp-dao-python-server-dev /bin/sh
```

## コンテナのbuild

```
cd backend
docker-compose build
```

## 開発環境の構築

localの場合はcontractsのhardhatを立ち上げる

=====
1. contractを動かせる環境を構築
     pythonと同時にguncheをup (localとgitHubActionの両方)
2. main.pyでコードを記述

ここから準備
  2-0.  　従業員を作成　　サーバー
  2-0-1. アドレスを登録  サーバー
  2-0-2. アドレスのチェック用認証トークンを送って正しいことをチェック　サーバー
  2-0-3. 送られらことを従業員が確認してトークンをコントラクトに送る

  2-1. EmployeeAuthorityWorkerNFTをmint これはbatchが良いね。


3. contractのversion管理が必要

testnetのgitHubActionを用意



コントラクトの管理は

定数でいいかな。。。

# chain
# 環境
# address

の入れ子かな。。。
