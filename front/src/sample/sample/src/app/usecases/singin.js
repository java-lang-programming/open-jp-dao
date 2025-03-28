import { SiweMessage } from 'siwe';
import { fetchSessionsNonce, postSessionsSignin } from "../repo/sessions";

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
    // TODO これはslackいき
    console.error(err);
    const error = new Error("postSessionsSignin error");
    error.code = "ERROR_POST_SESSION_SIGNIN_ERROR";
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