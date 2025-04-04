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

or

make dc_build 
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


make dc_up

docker exec -it open-dao-front-dev /bin/sh

cdd sample
cd sample

npm run dev


====
import Image from "next/image";
import { useEffect, useState } from 'react';
import { BrowserProvider } from 'ethers';
import Link from 'next/link';
import { fetchSessionsNonce, postSessionsSignin } from "./repo/sessions";
import { makeMessage } from "./usecases/singin";
import { ForeignExchangeGainIndex, DollarYenTransactionsIndex } from "./page_urls";
import { useRouter } from 'next/navigation';
import "./login.css";

// 共通のエラーハンドリング関数
const handleError = (err, customMessage) => {
  alert(customMessage);
  console.error(err);
  setErrors([...errors, { "code": "error_code", "msg": customMessage }]);
};

// 共通のAPI呼び出し関数
const apiCall = async (url, options) => {
  try {
    const response = await fetch(url, options);
    return await response.json();
  } catch (err) {
    handleError(err, "API呼び出しに失敗しました");
    throw err;
  }
};

const Header = () => (
  <header>
    <div className="header1">
      <div>
        <a href="#" className="header1_site_name">EKISA</a>
      </div>
      <nav className="header1_nav">
        <div>
          <button className="btn_sign">ログアウト</button>
        </div>
      </nav>
    </div>
    <div className="header2">
      <div>
        <ul className="header2_nav">
          <li><a href="#" className="header2_nav_li">Home</a></li>
          <li><a href="#" className="header2_nav_li">お知らせ・ご案内</a></li>
        </ul>
      </div>
    </div>
  </header>
);

const MainContent = ({ errors, providers, handleConnect }) => (
  <div className="main">
    <div className="main_content">
      <p className="title-font font-medium text-3xl text-gray-900">ウォレットをお持ちの方はログインしてください</p>
      <div>
        {errors.length > 0 && errors.map((e) => (
          <div className="login_error" key={e.code}>
            <p>{e.msg}</p>
          </div>
        ))}
        {providers.length > 0 ? providers.map((provider) => (
          <button key={provider.info.uuid} onClick={() => handleConnect(provider)} >
            <img src={provider.info.icon} alt={provider.info.name} width="100" height="100" />
          </button>
        )) : <div>there are no Announced Providers</div>}
      </div>
      <p className="text-xs text-gray-500 mt-3">ログインできない場合</p>
    </div>
  </div>
);

// メイン関数
export default function Home() {
  const router = useRouter();
  const [providers, setProviders] = useState([]);
  const [address, setAddress] = useState("");
  const [errors, setErrors] = useState([]);

  const handleLogout = async () => {
    try {
      const res = await fetch(`http://localhost:3000/apis/sessions/signout`, {
        method: "POST",
        headers: {
          'Content-Type': 'application/json',
        },
        mode: 'cors',
        credentials: 'include'
      });
      if (res.status === 201) {
        setAddress("");
      }
    } catch (err) {
      handleError(err, "ログアウトに失敗しました");
    }
  };

  const verify = async () => {
    try {
      await fetch(`http://localhost:3000/apis/sessions/verify`, {
        method: "POST",
        headers: {
          'Content-Type': 'application/json',
        },
        mode: 'cors',
        credentials: 'include'
      });
    } catch (err) {
      handleError(err, "権限の確認に失敗しました");
    }
  };

  const handleConnect = async (providerWithInfo) => {
    try {
      const accounts = await providerWithInfo.provider.request({ method: 'eth_requestAccounts' });
      if (accounts?.[0]) {
        const account = accounts[0];
        const provider = new BrowserProvider(providerWithInfo.provider);
        const signer = await provider.getSigner();
        const network = await provider.getNetwork();
        const chainId = String(Number(network.chainId));

        const response = await fetchSessionsNonce();
        const nonce_result = await response.json();

        const message = makeMessage(window.location.protocol.slice(0, -1), window.location.host, window.location.origin, signer.address, chainId, nonce_result.nonce);
        const signature = await signer.signMessage(message);

        const obj = { chain_id: chainId, message: message, signature: signature, nonce: nonce_result.nonce, domain: window.location.host, address: signer.address, kind: 1 };
        const body = JSON.stringify(obj);

        const res = await postSessionsSignin(body);
        if (res.status === 201) {
          router.push(DollarYenTransactionsIndex);
        }
      }
    } catch (err) {
      handleError(err, "ログインに失敗しました");
    }
  };

  const providerDetails = async () => {
    let providerDetails = [];
    function onAnnouncement(event) {
      providerDetails.push(event.detail);
    }
    window.addEventListener("eip6963:announceProvider", onAnnouncement);
    window.dispatchEvent(new Event("eip6963:requestProvider"));
    window.removeEventListener("eip6963:announceProvider", onAnnouncement);
    return providerDetails;
  };

  useEffect(() => {
    const fetchProviders = async () => {
      const providers = await providerDetails();
      setProviders(providers);
    };
    fetchProviders();
  }, []);

  return (
    <div>
      <Header />
      <MainContent errors={errors} providers={providers} handleConnect={handleConnect} />
      {address && <p>{address}</p>}
      {address && <button onClick={handleLogout}><div>ログアウト</div></button>}
    </div>
  );
}