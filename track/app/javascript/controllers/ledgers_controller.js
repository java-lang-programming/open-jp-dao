import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ledgers"
export default class extends Controller {
  static targets = ["checkbox", "deleteButton", "modal", "itemInfo"]
  connect() {
    this.update()
  }

  update() {
    const hasSelection = this.checkboxTargets.some(cb => cb.checked)

    if (this.hasDeleteButtonTarget) {
      this.deleteButtonTarget.disabled = !hasSelection
      this.deleteButtonTarget.classList.toggle("opacity-50", !hasSelection)
      this.deleteButtonTarget.classList.toggle("cursor-not-allowed", !hasSelection)
    }
  }

  // モーダルを開く
  openModal() {
    const checkedRows = this.checkboxTargets
        .filter(cb => cb.checked)
        .map(cb => cb.closest('.item-row'))

    // 選択された名称を取得
    const names = checkedRows.map(row => row.querySelector('.item-name').textContent.trim())
    this.itemInfoTarget.textContent = names.join(', ')

    this.modalTarget.classList.remove('hidden')
  }

  // モーダルを閉じる
  closeModal(event) {
    if (event) {
      // 1. 背景（modalTarget本体）をクリックしたか
      const isBackground = event.target === this.modalTarget

      // 2. 「閉じる」クラスを持つボタン（またはその子要素のSVG等）をクリックしたか
      const isCloseButton = event.target.closest('.close-modal-button')

      // 背景でも閉じボタンでもなければ、何もしない（モーダル内側クリックで閉じないようにする）
      if (!isBackground && !isCloseButton) return
    }
    // イベントのデフォルト挙動（aタグなら遷移など）を止める
    this.modalTarget.classList.add('hidden')
  }

  // 削除実行（フォーム送信）
  confirmDelete() {
    const checkedIds = this.checkboxTargets
        .filter(cb => cb.checked)
        .map(cb => cb.value)

    if (checkedIds.length > 0) {
      const form = document.createElement('form')
      form.method = 'POST'
      // URLの先頭にスラッシュを入れて絶対パスにするのが安全です
      form.action = 'ledgers/destroy_multiple'

      // CSRFトークンの追加
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      const csrfInput = document.createElement('input')
      csrfInput.type = 'hidden'
      csrfInput.name = 'authenticity_token'
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)

      // IDを配列形式で追加
      checkedIds.forEach(id => {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = 'ledger_ids[]'
        input.value = id
        form.appendChild(input)
      })

      document.body.appendChild(form)
      form.submit()

      // モーダルを閉じる
      this.modalTarget.classList.add('hidden')
    }
  }
}
