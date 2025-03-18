
import "@hotwired/turbo-rails"
// // Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// alert("sss");
// // import { useEffect, useState } from 'react';
// // import {ethers} from 'ethers';
// // import { SiweMessage } from 'siwe';
// import { BrowserProvider } from 'ethers';
// alert("aaaa");

// https://github.com/takeyuweb/rails-importmap-demo/blob/main/app/javascript/hello_react/hello.js
//   const onClickMetaMask = async () => {
//   	console.log("aaaa");
//     const providerWithInfo = await fetchMetaMask();
//     //console.log(providerWithInfo);

//     let accounts = null
//     try {
//       accounts = await providerWithInfo.provider.request({method:'eth_requestAccounts'})
//     } catch (err) {
//       console.log(err);
//       const user_rejected_request_code = 4001
//       if (err.code === user_rejected_request_code) {
//         const container = document.getElementById("siginin_error");
//         container.innerHTML = `<p>リクエストがキャンセルされました。</p>`;
//         return
//       }
//     }

//     if (accounts?.[0]) {
//       const account = accounts?.[0];
//       const provider = new BrowserProvider(providerWithInfo.provider);
//       const signer = await provider.getSigner();
//       console.log(signer.address);
//       const network = await provider.getNetwork();
//       const chainId = String(Number(network.chainId));
//       console.log(chainId) // 1337

//       // 3000
//       // http://localhost:8001/api/nonce
//       // https://qiita.com/harururu32/items/c372c825ee8c9f90caa3#%E3%83%A6%E3%83%8B%E3%83%83%E3%83%88%E3%83%86%E3%82%B9%E3%83%88
//       // const response = await fetch('http://localhost:3000/apis/sessions/nonce', {mode: 'cors', credentials: 'include'})
//       let nonce_result = null;
//       try {
//         // ここはtopで取得
//         const response = await fetchSessionsNonce()
//         nonce_result = await response.json();
//       } catch (err) {
//         console.error(err);
//         // TODO
//         // エラーを送信する developersで閲覧可能にする
//         // ここでエラーを作成する
//         // setErrors([{"code": "aaaa", "msg": "ログインに失敗しました。"}]);
//         return
//       }

//       // TODO responseのチェックでnonceがなければエラー表示
//       // 本番とdivでは異なる
//       // const nonce_result = await response.json();

//       console.log(nonce_result)
//       console.log(nonce_result.nonce);

//       // TODO nonceを保存しておくこと！

//       // ここからは毎回
//       const scheme = window.location.protocol.slice(0, -1);
//       const domain = window.location.host;
//       const origin = window.location.origin;
//       const address = signer.address;
//       //const statement = 'Sign in with Ethereum to the app.';

//       // メッセージを作成
//       const message = makeMessage(scheme, domain, origin, address, chainId, nonce_result.nonce)
      
//       // メッセージにサイン
//       let signature = null;
//       try {
//         // ここでrailsに投げる
//         signature = await signer.signMessage(message);
//       } catch (err) {
//         alert("ここでエラー");
//         alert(err);
//         console.error(err);
//         return
//       }
//       // signatureも保存


//       const obj = { chain_id: chainId, message: message, signature: signature, nonce: nonce_result.nonce, domain:  domain, address: address, kind: 1};
//       const body = JSON.stringify(obj);

//       const res = await postSessionsSignin(body)

//       const verify_status = await res.status
//       if (verify_status == 201) {
//         router.push(ForeignExchangeGainIndex)
//         // setAddress(address)
//         return
//       }
//     }  
//   }

//   const providerDetails = async () => {
//     let providerDetails = [];
//     function onAnnouncement(event) {
//       providerDetails.push(event.detail)
//     }
//     window.addEventListener("eip6963:announceProvider", onAnnouncement);
//     // これでannounceProviderを呼び出す
//     window.dispatchEvent(new Event("eip6963:requestProvider"));
//     // remove
//     window.removeEventListener("eip6963:announceProvider", onAnnouncement);
//     return providerDetails;
//   }


//   const fetchMeatamaskProvider = async () => {
//     const providerWithInfo = await fetchMetaMask();
//     if (providerWithInfo === null) {
//       // TODO ここは外だし
//       const container = document.getElementById("siginin");
//       container.innerHTML = '<p>ログインにはMetaddddMaskが必要です。</p><p>MetaMaskを<a href="https://support.metamask.io/ja/start/getting-started-with-metamask/" target="_blank">install</a>してください</p>';
//       return
//     }

//     // metamask
//     const container = document.getElementById("siginin");
//     container.innerHTML = `<button key=${providerWithInfo.info.uuid} onclick="onClickMetaMask()" ><img src=${providerWithInfo.info.icon} alt=${providerWithInfo.info.name} width="100" height="100" /></button>`;
//   }

//   const fetchMetaMask = async () => {
//     const providers = await providerDetails();
//     // metamaskだけ取り出し
//     const filteredProviders = providers.filter((provider) => provider.info.name === "MetaMask");
//     return filteredProviders.length　=== 0 ? null : filteredProviders[0];
//   }

//   fetchMeatamaskProvider();


