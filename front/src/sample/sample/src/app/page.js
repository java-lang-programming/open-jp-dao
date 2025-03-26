'use client';

import Image from "next/image";
import { useEffect, useState } from 'react';
import { BrowserProvider } from 'ethers';
import Link from 'next/link';
import "./login.css";
import { postSessionsSignin } from "./repo/sessions";
import { makeMessage, requestEthAccountsViaMetamask, nonceResponse, makePostSessionsSigninBody, sessionsSigninResponse } from "./usecases/singin";
import { ForeignExchangeGainIndex, DollarYenTransactionsIndex } from "./page_urls";
import { useRouter } from 'next/navigation'


// https://1.x.wagmi.sh/
// https://docs.metamask.io/wallet/how-to/connect/
// https://docs.metamask.io/wallet/reference/eth_requestaccounts/
export default function Home() {
  const router = useRouter();

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
        // TODO nonceを保存しておくこと！

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
        alert(body);

        // const obj = { chain_id: chainId, message: message, signature: signature, nonce: nonce, domain:  domain, address: address, kind: 1};
        // const body = JSON.stringify(obj);

        const verify_status = await sessionsSigninResponse(body)

        // const verify_status = await res.status
        if (verify_status.status == 201) {
          router.push(DollarYenTransactionsIndex)
          // setAddress(address)
          return
        }
      }
    } catch (err) {
      if (err.code === "ERROR_MATAMASK_ETH_REQUEST_ACCOUNTS") {
        setErrors([{"code": err.code, "msg": "METAMASKのリクエストを処理中です。METAMASKの状態を確認してください。"}]);
      } else if (err.code === "ERROR_FETCH_SESSION_NONCE_ERROR") {
        // TODO Frontのログインで発生発生したエラー　番号を管理すること
        setErrors([{"code": err.code, "msg": "予期せぬエラーでログインに失敗しました。管理者に連絡してください。エラーコードはF0001です。"}]);
      } else if (err.code === "ERROR_POST_SESSION_SIGNIN_ERROR") {
        setErrors([{"code": err.code, "msg": "予期せぬエラーでログインに失敗しました。管理者に連絡してください。エラーコードはF0002です。"}]);
      }
    }  
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
    };

    fetchProviders();    
  }, []);

  return (
    <div>
    <div class="container">
      <header>
        
        <div class="header1">
          <div>
            <Link className="header1_site_name" href="/">Wan<sup>2</sup></Link>
          </div>

          <nav
            class="header1_nav">
            <div>
              <button class="btn_sign">ログアウト</button>
            </div>
          </nav>
        </div>

      </header>

      <div class="main">
        <div class="main_content">
          <p class="title-font font-medium text-3xl text-gray-900">ウォレットをお持ちの方はログインしてください</p>
          <div>
          {
            errors.length > 0 && errors.map((e) => (
              <div class="login_error">
                <p>{e.msg}</p>
              </div>
            ))
          }
          {
            providers.length > 0 ? providers?.map((provider)=>(
              <button key={provider.info.uuid} onClick={()=>handleConnect(provider)} >
                <img src={provider.info.icon} alt={provider.info.name} width="100" height="100" />
              </button>
          )) : 
            <div>
              <p>MetaMaskを検出できませんでした。</p>
              <p>ブラウザに<a href="https://metamask.io/download" target="blank">MetaMaskをダウンロード</a>してログインしてください。</p>
            </div>
          }            
          </div>
          <p class="text-xs text-gray-500 mt-3">ログインできない場合</p>
        </div>
      </div>
    </div>

    <div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col gap-8 row-start-2 items-center sm:items-start">
        <Image
          className="dark:invert"
          src="https://nextjs.org/icons/next.svg"
          alt="Next.js logo"
          width={180}
          height={38}
          priority
        />
        <ol className="list-inside list-decimal text-sm text-center sm:text-left font-[family-name:var(--font-geist-mono)]">
          <li className="mb-2">
            Get started by editing{" "}
            <code className="bg-black/[.05] dark:bg-white/[.06] px-1 py-0.5 rounded font-semibold">
              src/app/page.js
            </code>
            .
          </li>
          <li>Save and see your changes instantly.</li>
          <li><Link href="/dollaryenledgers">外貨預金元帳ドル円一覧</Link></li>
        </ol>
        {
          address && (<p>{address}</p>)
        }
        {
          address && (
            <button onClick={()=>handleLogout()} >
              <div>ログアウト</div>
            </button>)
        }
        <div>
          <h2>項目</h2>
          <p><Link href="/dollaryenledgers">外貨預金元帳ドル円一覧</Link></p>
          <p><Link href="/dollar_yens">ドル円一覧</Link></p>
        </div>
        <div className="flex gap-4 items-center flex-col sm:flex-row">
          <a
            className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-foreground text-background gap-2 hover:bg-[#383838] dark:hover:bg-[#ccc] text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
            href="https://vercel.com/new?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
            target="_blank"
            rel="noopener noreferrer"
          >
            <Image
              className="dark:invert"
              src="https://nextjs.org/icons/vercel.svg"
              alt="Vercel logomark"
              width={20}
              height={20}
            />
            Deploy now
          </a>
          <a
            className="rounded-full border border-solid border-black/[.08] dark:border-white/[.145] transition-colors flex items-center justify-center hover:bg-[#f2f2f2] dark:hover:bg-[#1a1a1a] hover:border-transparent text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 sm:min-w-44"
            href="https://nextjs.org/docs?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
            target="_blank"
            rel="noopener noreferrer"
          >
            Read our docs
          </a>
        </div>
      </main>
      <footer className="row-start-3 flex gap-6 flex-wrap items-center justify-center">
        <a
          className="flex items-center gap-2 hover:underline hover:underline-offset-4"
          href="https://nextjs.org/learn?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            aria-hidden
            src="https://nextjs.org/icons/file.svg"
            alt="File icon"
            width={16}
            height={16}
          />
          Learn
        </a>
        <a
          className="flex items-center gap-2 hover:underline hover:underline-offset-4"
          href="https://vercel.com/templates?framework=next.js&utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            aria-hidden
            src="https://nextjs.org/icons/window.svg"
            alt="Window icon"
            width={16}
            height={16}
          />
          Examples
        </a>
        <a
          className="flex items-center gap-2 hover:underline hover:underline-offset-4"
          href="https://nextjs.org?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            aria-hidden
            src="https://nextjs.org/icons/globe.svg"
            alt="Globe icon"
            width={16}
            height={16}
          />
          Go to nextjs.org →
        </a>
      </footer>
    </div>
    </div>
  );
}
