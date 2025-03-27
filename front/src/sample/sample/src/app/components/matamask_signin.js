import { useState } from 'react';
import { requestEthAccountsViaMetamask, ERROR_MATAMASK_ETH_REQUEST_ACCOUNTS } from "../usecases/singin";

export default async function MetamaskSignin({ provider }) {
  const [errors, setErrors] = useState([]);
  console.log("MetamaskSignin")
  try {
    const accounts = await requestEthAccountsViaMetamask(provider);
  } catch (err) {
  	if (err.code === ERROR_MATAMASK_ETH_REQUEST_ACCOUNTS) {
  	  errors.push({"code": err.code, "msg": "METAMASKのリクエストを処理中です。METAMASKの状態を確認してください。"});
    } 
  }
  return (
    <div>
      <p class="title-font font-medium text-3xl text-gray-900">MetaMaskアイコンをクリックしてログインしてください</p>
      <div>
      {
        errors.length > 0 && errors.map((e) => (
          <div class="login_error">
            <p>{e.msg}</p>
          </div>
        ))
      }
      {
        shouldLoad === false && providers.length > 0 ? providers?.map((provider)=>(
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
  );
}
