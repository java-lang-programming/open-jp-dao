import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  connect() {
    // 2秒後に自動で close メソッドを呼ぶ
    this.timeout = setTimeout(() => {
      this.close()
    }, 2000)
  }

  // クリーンアップ（念のため）
  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  close() {
    // 透明にしながら、ごくわずかに上に浮かせる
    this.element.style.pointerEvents = "none" // 連打防止
    this.element.classList.add("opacity-0", "-translate-y-2")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
