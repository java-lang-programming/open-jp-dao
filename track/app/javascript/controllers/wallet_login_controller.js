import { Controller } from "@hotwired/stimulus"
import { requestEthAccountsViaMetamask, nonceResponse, makeMessage, makePostSessionsSigninBody, sessionsSigninResponse } from "usecases/singin"
import { BrowserProvider } from 'ethers'
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="wallet-login"
export default class extends Controller {
  connect() {
    this.providers = { evm: [], solana: null }
    this.boundOnAnnouncement = this.onAnnouncement.bind(this) // bindが必要
    this.startProviderDiscovery()
  }

  async login(event) {
    event.preventDefault(); // リンクの遷移などを止める
    try {
      const providerWithInfo = this.providers.evm[0]
      const accounts = await requestEthAccountsViaMetamask(providerWithInfo)

      if (accounts?.[0]) {
        const provider = new BrowserProvider(providerWithInfo.provider)
        const signer = await provider.getSigner()
        const network = await provider.getNetwork()
        const chainId = String(Number(network.chainId))
        console.log(chainId)

        const res_nonce = await nonceResponse();
        const nonce = res_nonce.nonce;
        console.log(chainId)
        console.log(nonce)

        // ここからは毎回
        const scheme = window.location.protocol.slice(0, -1)
        const domain = window.location.host
        const origin = window.location.origin
        const address = signer.address

        // メッセージを作成
        const message = makeMessage(scheme, domain, origin, address, chainId, nonce);
        // メッセージにサイン
        const signature = await signer.signMessage(message);
        console.log(signature)
        // signatureも保存
        const body = makePostSessionsSigninBody(chainId, message, signature, nonce, domain, address)

        const res_signin = await sessionsSigninResponse(body)

        // const verify_status = await res.status
        if (res_signin.status == 201) {
          // setSignin(true);
          // ここで認証に成功しましたがるとさらに良い。
          Turbo.visit("/dollar_yen_transactions/foreign_exchange_gain")
          return
        }
      }
    } catch (err) {
      console.log(err);
      if (err.code === ERROR_MATAMASK_ETH_REQUEST_ACCOUNTS) {
        setErrors([{"code": err.code, "msg": "MetaMaskのリクエストを処理中です。MetaMaskの状態を確認してください。(画面右上でMetaMaskが起動状態になっていませんか？)"}]);
      } else if (err.code === "ERROR_FETCH_SESSION_NONCE_ERROR") {
        setErrors([{"code": err.code, "msg": `予期せぬエラーでログインに失敗しました。管理者に連絡してください。エラーコードは${Constants.FS01R001}です。`}]);
      } else if (err.code === "ERROR_POST_SESSION_SIGNIN_ERROR") {
        setErrors([{"code": err.code, "msg": `予期せぬエラーでログインに失敗しました。管理者に連絡してください。エラーコードは${Constants.FS01R002}です。`}]);
      }
    }


  }

  // ページから離れた時にリスナーを掃除する（メモリリーク防止）
  disconnect() {
    this.stopProviderDiscovery()
  }

  // 1. 探索開始
  startProviderDiscovery() {
    window.addEventListener("eip6963:announceProvider", this.boundOnAnnouncement)
    window.dispatchEvent(new Event("eip6963:requestProvider"))

    // タイムアウト監視を分離
    this.discoveryTimeout = setTimeout(() => {
      this.handleDiscoveryTimeout()
    }, 1500)
  }

  // 2. プロバイダーが見つかった時のコールバック
  onAnnouncement(event) {
    const providerDetail = event.detail
    
    if (providerDetail.info.name === 'MetaMask') {
      // 重複登録防止
      if (!this.providers.evm.some(p => p.info.uuid === providerDetail.info.uuid)) {
        console.log(providerDetail)
        console.log("metamask発見")
        this.providers.evm.push(providerDetail)
        // this.showLoginUI()
      }
    }
  }

  // 4. 探索の終了（後片付け）
  stopProviderDiscovery() {
    window.removeEventListener("eip6963:announceProvider", this.boundOnAnnouncement)
    if (this.discoveryTimeout) clearTimeout(this.discoveryTimeout)
  }

  // 5. タイムアウト時の最終判定
  handleDiscoveryTimeout() {
    this.stopProviderDiscovery()
    
    if (this.providers.evm.length === 0) {
      alert("MetaMaskが見つかりませんでした。拡張機能を確認してください。")
      console.log("MetaMaskが見つかりませんでした。拡張機能を確認してください。")
    //   this.placeholderTarget.textContent = "MetaMaskが見つかりませんでした。拡張機能を確認してください。"
    }
  }
}
