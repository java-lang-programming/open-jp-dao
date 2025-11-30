import { SiweMessage } from 'siwe';
import { fetchSessionsNonce, postSessionsSignin, postVerify } from "../repo/sessions";
import { postSolanasSignin } from "../repo/solanas";

export const ERROR_MATAMASK_ETH_REQUEST_ACCOUNTS = "ERROR_MATAMASK_ETH_REQUEST_ACCOUNTS";
export const ERROR_FETCH_SESSION_NONCE_ERROR = "ERROR_FETCH_SESSION_NONCE_ERROR";
export const ERROR_POST_SESSION_SIGNIN_ERROR = "ERROR_POST_SESSION_SIGNIN_ERROR";

/**
//  * @description メッセージを作成する
//  * @function 
//  */
export const makeMessage = (scheme, domain, origin, address, chainId, nonce)=> {
  const statement = 'Sign in with Ethereum to the WanWan.';
      
  const siweMessage = new SiweMessage({
    scheme,
    domain,
    address,
    statement,
    uri: origin,
    version: '1',
    chainId: chainId,
    nonce: nonce
  });

  return siweMessage.prepareMessage();
}

/**
//  * @description metamaskを介してアカウントを取得する
//  * @function
//  */
export const requestEthAccountsViaMetamask = async(providerWithInfo) => {
  let accounts = null
  try {
    return await providerWithInfo.provider.request({method:'eth_requestAccounts'})
  } catch (err) {
    // console.error(err);
    const error = new Error("Already processing eth_requestAccounts. Please wait.");
    error.code = "ERROR_MATAMASK_ETH_REQUEST_ACCOUNTS";
    throw error;
  }
}

/**
//  * @description Phantomを介してアカウントを取得する
//  * @function
//  */
export const connectSolanaViaPhantom = async(providerWithInfo) => {
  let accounts = null
  try {
    // ウォレット接続
    return await providerWithInfo.connect({ onlyIfTrusted: true });
  } catch (err) {
    if (err.code === 4001) {
      const error = new Error("Phantom wallet connection was cancelled by the user.");
      error.code = "PHANTOM_CONNECT_CANCELLED";
      // 以下を画面に出したい
      console.log("ウォレット接続がキャンセルされました");
      return;
    }
    console.log(err.code);
    // if (err.code === "PHANTOM_CONNECT_CANCELLED") {
    //   // ユーザーが閉じただけ → 何もしない or UI 表示
    //   console.log("ウォレット接続がキャンセルされました");
    //   return;
    // }

    // if (err.code === "PHANTOM_ALREADY_CONNECTED") {
    //   // すでに接続済み → 再度 connect しない
    //   console.log("すでに接続済みです");
    //   return;
    // }

    // その他のエラー
    // showToast("Phantomへの接続に失敗しました");
  }
}

/**
//  * @description pythonのnonce apiを呼び出す
//  * @function
//  */
export const nonceResponse = async() => {
  try {
    const response = await fetchSessionsNonce()
    return await response.json();
  } catch (err) {
    // TODO これはslackいき
    console.error(err);
    const error = new Error("fetchSessionsNonce error");
    error.code = "ERROR_FETCH_SESSION_NONCE_ERROR";
    throw error;
  }
}

export const sessionsSigninResponse = async(body) => {
  try {
    return await postSessionsSignin(body)
  } catch (err) {
    // TODO これはapiにログを投げる tagでフロント
    console.error(err);
    const error = new Error("postSessionsSignin error");
    error.code = "ERROR_POST_SESSION_SIGNIN_ERROR";
    throw error;
  }
}

export const solanaSigninResponse = async(body) => {
  try {
    return await postSolanasSignin(body)
  } catch (err) {
    // TODO これはapiにログを投げる
    console.error(err);
    const error = new Error("postSolanasSignin error");
    error.code = "ERROR_POST_SESSION_SIGNIN_ERROR";
    throw error;
  }
}

export const sessionsVerifyResponse = async() => {
  try {
    return await postVerify()
  } catch (err) {
    // TODO これはslackいき
    console.error(err);
    const error = new Error("sessionsVerifyResponse error");
    error.code = "ERROR_POST_SESSION_VERIFY_ERROR";
    throw error;
  }
}

export const makePostSessionsSigninBody = (chainId, message, signature, nonce, domain, address) => {
  const obj = {
    chain_id: chainId,
    message: message,
    signature: signature,
    nonce: nonce,
    domain:  domain,
    address: address,
    kind: 1
  };
  return JSON.stringify(obj);
}

// makePostSolanaSigninBody(message, publicKey, bs58signature)
export const makePostSolanaSigninBody = (message, publicKey, bs58signature) => {
  const obj = {
    public_key: publicKey,
    signature_b58: bs58signature,
    message,
    kind: 2
  };
  return JSON.stringify(obj);
}


// /**
//  * @description rails apiに接続してsigninする
//  * @function 
//  */
// export const postSessionsSignin = async(body)=> {
//   return await fetch(`${ApiBaseUrl}/apis/sessions/signin`, {
//     method: "POST",
//     headers: {
//       'Content-Type': 'application/json',
//     },
//     body: body,
//     mode: 'cors',
//     credentials: 'include'
//   })
// }

// 