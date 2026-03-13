import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["container"]

  // モーダルを開く
  open() {
    this.containerTarget.classList.remove("hidden")
    this.containerTarget.classList.add("flex")
    // 背景のスクロールを止めたい場合は以下を追加
    document.body.classList.add("overflow-hidden")
  }

  // モーダルを閉じる
  close() {
    this.containerTarget.classList.add("hidden")
    this.containerTarget.classList.remove("flex")
    document.body.classList.remove("overflow-hidden")
  }
}
