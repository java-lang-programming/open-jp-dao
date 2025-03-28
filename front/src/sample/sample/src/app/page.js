'use client';

import Image from "next/image";
import { useEffect, useState, Suspense } from 'react';
import { BrowserProvider } from 'ethers';
import Link from 'next/link';
import "./login.css";
import Constants from "./models/errors";
import { postSessionsSignin } from "./repo/sessions";
import MetamaskSignin from "./components/matamask_signin";
import Eip6963Loading from "./components/sessions/eip6963_loading";
import SigninLoading from "./components/sessions/signin_loading";
import MetamaskNotFound from "./components/sessions/metamask_not_found";
import { makeMessage, requestEthAccountsViaMetamask, nonceResponse, makePostSessionsSigninBody, sessionsSigninResponse, ERROR_MATAMASK_ETH_REQUEST_ACCOUNTS } from "./usecases/singin";
import { ForeignExchangeGainIndex, DollarYenTransactionsIndex } from "./page_urls";
import { useRouter } from 'next/navigation'


// https://1.x.wagmi.sh/
// https://docs.metamask.io/wallet/how-to/connect/
// https://docs.metamask.io/wallet/reference/eth_requestaccounts/
export default function Home() {
  const router = useRouter();

  // 複数ロード
  const [walletLoad, setWalletLoad] = useState(false);
  const [walletProcessing, setWalletProcessing] = useState(false);
  const [provider, setProvider] = useState(null);
  const [providers, setProviders] = useState([]);
  const [address, setAddress] = useState("");
  const [errors, setErrors] = useState([]);

  const handleLogout = async()=> {
    const res = await fetch(`http://localhost:3000/apis/sessions/signout`, {
        method: "POST",
        headers: {
          'Content-Type': 'application/json',
        },
        mode: 'cors',
        credentials: 'include'
    });

    const verify_status = await res.status
    if (verify_status == 201) {
      setAddress("")
      return
    }
  }

  // 権限があるかを首藤
  const verify = async()=> {
    const res = await fetch(`http://localhost:3000/apis/sessions/verify`, {
        method: "POST",
        headers: {
          'Content-Type': 'application/json',
        },
        mode: 'cors',
        credentials: 'include'
    });

    const verify_status = await res.status
  }


  // https://qiita.com/harururu32/items/c372c825ee8c9f90caa3#%E3%83%A6%E3%83%8B%E3%83%83%E3%83%88%E3%83%86%E3%82%B9%E3%83%88
  // エラーハンドリングも行うこと
  const handleConnect = async(providerWithInfo)=> {
    // setProvider(providerWithInfo);
    setWalletProcessing(true);
    // ここから下をmetamask signinでまとめる
    try {
      const accounts = await requestEthAccountsViaMetamask(providerWithInfo);

      if (accounts?.[0]) {
        const provider = new BrowserProvider(providerWithInfo.provider);
        const signer = await provider.getSigner();
        const network = await provider.getNetwork();
        const chainId = String(Number(network.chainId));

        // http://localhost:8001/api/nonce
        // https://qiita.com/harururu32/items/c372c825ee8c9f90caa3#%E3%83%A6%E3%83%8B%E3%83%83%E3%83%88%E3%83%86%E3%82%B9%E3%83%88
        const res_nonce = await nonceResponse();
        const nonce = res_nonce.nonce;

        // ここからは毎回
        const scheme = window.location.protocol.slice(0, -1);
        const domain = window.location.host;
        const origin = window.location.origin;
        const address = signer.address;

        // メッセージを作成
        const message = makeMessage(scheme, domain, origin, address, chainId, nonce);
        // メッセージにサイン
        const signature = await signer.signMessage(message);
        // signatureも保存
        const body = makePostSessionsSigninBody(chainId, message, signature, nonce, domain, address);

        const verify_status = await sessionsSigninResponse(body)

        // const verify_status = await res.status
        if (verify_status.status == 201) {
          router.push(DollarYenTransactionsIndex)
          // setAddress(address)
          return
        }
      }
    } catch (err) {
      if (err.code === ERROR_MATAMASK_ETH_REQUEST_ACCOUNTS) {
        setErrors([{"code": err.code, "msg": "MetaMaskのリクエストを処理中です。MetaMaskの状態を確認してください。(画面右上でMetaMaskが起動状態になっていませんか？)"}]);
      } else if (err.code === "ERROR_FETCH_SESSION_NONCE_ERROR") {
        setErrors([{"code": err.code, "msg": `予期せぬエラーでログインに失敗しました。管理者に連絡してください。エラーコードは${Constants.FS01R001}です。`}]);
      } else if (err.code === "ERROR_POST_SESSION_SIGNIN_ERROR") {
        setErrors([{"code": err.code, "msg": `予期せぬエラーでログインに失敗しました。管理者に連絡してください。エラーコードは${Constants.FS01R002}です。`}]);
      }
    }
    setWalletProcessing(false);  
  }


  const providerDetails = async () => {
    let providerDetails = [];
    function onAnnouncement(event) {
      if (event.detail.info.name === 'MetaMask') {
        providerDetails.push(event.detail);
      }
    }
    window.addEventListener("eip6963:announceProvider", onAnnouncement);
    // これでannounceProviderを呼び出す
    window.dispatchEvent(new Event("eip6963:requestProvider"));
    // remove
    window.removeEventListener("eip6963:announceProvider", onAnnouncement);
    return providerDetails;
  }

  useEffect(() => {
    const fetchProviders = async () => {
       const providers = await providerDetails();
       setProviders(providers)
       setWalletLoad(true)
    };

    fetchProviders();    
  }, []);

  return (
    <div>
      <div className="container">
        <header>
          
          <div className="header1">
            <div>
              <Link className="header1_site_name" href="/">Wan<sup>2</sup></Link>
            </div>
          </div>

        </header>

        <div className="main">
          <div>
            <div className="main_content">
              { walletLoad === false && (
                <Eip6963Loading />
              )}
              { walletLoad === true && (
                <div>
                  {
                    walletProcessing === false && providers.length > 0 && (
                      <p className="title-font font-medium text-3xl text-gray-900">MetaMaskアイコンをクリックしてログインしてください</p>
                    )
                  }
                  <div>
                  {
                    errors.length > 0 && errors.map((e) => (
                      <div className="login_error">
                        <p>{e.msg}</p>
                      </div>
                    ))
                  }
                  {
                    walletProcessing === false && providers.length > 0 && providers.map((provider)=>(
                        <button key={provider.info.uuid} onClick={()=>handleConnect(provider)} >
                          <Image src={provider.info.icon} alt={provider.info.name} width="100" height="100" />
                        </button>
                      )
                    )
                  }
                  {
                    walletProcessing === false && providers.length == 0 && (
                      <MetamaskNotFound />
                    )
                  }
                  </div>
                  <p className="text-xs text-gray-500 mt-3"><Link href="/support">ログインできない場合</Link></p>
                </div>
              )}
            </div>
            {walletProcessing && (
              <SigninLoading />
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
