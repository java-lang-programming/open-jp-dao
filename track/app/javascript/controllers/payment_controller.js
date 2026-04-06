import { Controller } from "@hotwired/stimulus"
import { ethers } from "ethers"

// Connects to data-controller="payment"
export default class extends Controller {
  static targets = ["submitButton"]

  static values = {
    jpycAddress: String,
    paymentAddress: String,
    jpycAbiApprove: String
  }
  connect() {
    console.log(this.jpycAddressValue)
    console.log(this.paymentAddressValue)
    console.log(this.jpycAbiApproveValue)
  }

  async start(event) {
    event.preventDefault()
    this.submitButtonTarget.disabled = true
    const status = document.getElementById("status-message")

    try {
      const provider = new ethers.BrowserProvider(window.ethereum)
      const signer = await provider.getSigner()
      const userAddress = await signer.getAddress()

      // 1. Approve (JPYCの使用許可)
      status.innerText = "ステップ 1/2: JPYCの使用を承認中..."
      const jpycAddress = this.jpycAddressValue // Polygon JPYC
      const paymentContractAddress = this.paymentAddressValue // あなたの決済コントラクト
      const amount = ethers.parseUnits("330", 18)

      const jpyc = new ethers.Contract(jpycAddress, [this.jpycAbiApproveValue], signer)
      const approveTx = await jpyc.approve(paymentContractAddress, amount)
      await approveTx.wait()

      // 2. Payment (実際の決済)
      status.innerText = "ステップ 2/2: 支払いを確認中..."
      const paymentAbi = ["function payOneMonth() external"]
      const paymentContract = new ethers.Contract(paymentContractAddress, paymentAbi, signer)
      const payTx = await paymentContract.payOneMonth()
      
      // 3. Railsへ結果を送信 (ここが重要！)
      status.innerText = "サーバーで処理中..."
      await this.notifyRails(payTx.hash)

      status.innerText = "決済が完了しました！"
      // 成功したらリダイレクトなど
      // window.location.href = "/dashboard"

    } catch (error) {
      console.error(error)
      status.innerText = "エラーが発生しました: " + error.message
      this.submitButtonTarget.disabled = false
    }
  }
}
