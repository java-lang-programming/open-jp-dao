## contracts

0pen JP Daoで利用するcontractsコード

## コンテナに入る

docker exec -it open-jp-dao-contracts-dev /bin/sh

## Deployment

**Tech stack:**

- **hardhat** powers the REST API and other web pages

node v24.14.0
npm 11.10.1

## コンテナのbuild

```
cd contracts
docker-compose build
```

## コンテナに入る

```
docker-compose up
docker exec -it open-jp-dao-contracts-dev /bin/sh
```

## ライブラリインストール

```
npm install
```

## 動作確認

```
make unit_test
```

## 開発環境用意

1. nodeでhardhatの立ち上げ

別タブで

```
make launch_hardhat
```

2. deploy

```
make deploy_contracts_to_hardhat
```

## TODO

npmからpnpmにする
hardhatのversionを最新にして対応