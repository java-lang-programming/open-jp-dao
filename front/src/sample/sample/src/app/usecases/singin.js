import { SiweMessage } from 'siwe';
// export const requestAccounts = async (providerWithInfo) => {
//   let accounts
//   try {
//     await providerWithInfo.provider.request({method:'eth_requestAccounts'})
//   } catch (err) {
//     alert(err);
//     return err
//   }
//   return accounts
// }


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