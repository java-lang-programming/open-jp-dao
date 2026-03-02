import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="csv-upload"
export default class extends Controller {
  static targets = ["input", "dropArea", "list", "error", "submit", "status"]
  connect() {
    // 初期状態のボタン制御
    this.updateButtonState(false)
  }

  // 「ファイルを選択」ボタンをクリックした時
  browse() {
    this.inputTarget.click()
  }

  // ファイルが選択（change）またはドロップされた時
  handleFiles(event) {
    const files = event.target.files || event.dataTransfer.files
    this.validateAndDisplay(files)
  }

  // ドラッグ中のスタイル制御
  dragOver(event) {
    event.preventDefault()
    this.dropAreaTarget.classList.add('border-blue-500', 'bg-blue-50')
  }

  dragLeave(event) {
    event.preventDefault()
    this.dropAreaTarget.classList.remove('border-blue-500', 'bg-blue-50')
  }

  drop(event) {
    event.preventDefault()
    this.dragLeave(event)
    this.handleFiles(event)
  }

  // バリデーションと画面更新
  validateAndDisplay(files) {
    this.listTarget.innerHTML = ""
    this.errorTarget.classList.add('hidden')
    
    let validFiles = []
    let hasInvalidFile = false
    const fileArray = Array.from(files)

    if (fileArray.length === 0) {
      this.listTarget.innerHTML = '<li class="text-gray-500">ファイルが選択されていません</li>'
      this.updateButtonState(false)
      return
    }

    fileArray.forEach(file => {
      const listItem = document.createElement('li')
      if (this.isCsv(file)) {
        validFiles.push(file)
        listItem.textContent = file.name
        listItem.className = 'text-gray-700'
      } else {
        hasInvalidFile = true
        listItem.textContent = `${file.name} (不正な形式)`
        listItem.className = 'text-red-500 font-bold'
      }
      this.listTarget.appendChild(listItem)
    })

    // 不正なファイルが混じっている、または有効なファイルがゼロならエラー
    if (hasInvalidFile || validFiles.length === 0) {
      this.errorTarget.classList.remove('hidden')
      this.updateButtonState(false)
    } else {
      // 有効なファイルのみをinputにセットし直す
      this.syncInput(validFiles)
      this.updateButtonState(true)
    }
  }

  isCsv(file) {
    const validMimeTypes = ['text/csv', 'application/vnd.ms-excel', 'text/plain']
    return validMimeTypes.includes(file.type) || file.name.toLowerCase().endsWith('.csv')
  }

  syncInput(files) {
    const dataTransfer = new DataTransfer()
    files.forEach(file => dataTransfer.items.add(file))
    this.inputTarget.files = dataTransfer.files
  }

  updateButtonState(enabled) {
    this.submitTarget.disabled = !enabled
    if (enabled) {
      this.submitTarget.classList.remove('opacity-50', 'cursor-not-allowed')
    } else {
      this.submitTarget.classList.add('opacity-50', 'cursor-not-allowed')
    }
  }

  // 送信時のダミー処理
  submit(event) {
    this.statusTarget.textContent = 'CSVファイルをアップロード中...'
    this.statusTarget.className = 'mt-3 text-center text-sm text-blue-600'
  }
}
