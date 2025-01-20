## front

0pen JP Daoで利用するfrontコード

## コンテナに入る

docker exec -it open-dao-front-dev /bin/sh

## Deployment

**Tech stack:**

- **hardhat** powers the REST API and other web pages

node v18.17.1
npm 10.7.0

## コンテナのbuild

```
cd open-dao
docker-compose build
```

## コンテナに入る

```
docker-compose up
docker exec -it open-dao-front-dev /bin/sh
```

## ライブラリインストール

```
pnpm install
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

## コード

        if (provider !== null && provider.isMetaMask) {
          if (!provider.isConnected()) {
            alert("接続済み")

          } else {
            alert("非接続なので繋ぐよ");
            let addressList;
            let chainId;
            try {
              addressList = await window.ethereum.request({
		         "method": "eth_requestAccounts",
			     "params": []
			  });
			  chainId = await window.ethereum.request({ method: "eth_chainId" });
			} catch (error) {
			  // ここで処理は終わり
			  error(404, {
			    message: 'エラー'
		      });
			}

			alert(addressList);
			alert(chainId);

            //https://kit.svelte.jp/docs/errors
            // nonceの取得
            const response = await fetch('http://localhost:8001/api/nonce', {mode: 'cors'})
            console.log(response);
            const result = await response.json();
            alert(result.nonce);
            console.log(result);
          }

		} else {
		  alert("")
		}

# TODO 

1. pnpmにする
2. 開発サーバーの起動を簡単に

# 必要なサーバー

1. evmサーバー

cd /Users/masayasuzuki/workplace/study/open-jp-dao/contracts 
docker-compose up
docker exec -it open-jp-dao-contracts-dev /bin/sh
make launch_hardhat

2. python(コントラクト接続)

cd /Users/masayasuzuki/workplace/study/open-jp-dao/backend
docker-compose up
docker exec -it open-jp-dao-python-server-dev /bin/sh
make launch_dev_server

3. rails

cd /Users/masayasuzuki/workplace/study/open-jp-dao/track 
make dc_up
docker exec -it devcontainer_wevb3-rails-dev-app_1 /bin/sh
make dc_dev

4. front


cdd sample
cd sample

npm run dev
