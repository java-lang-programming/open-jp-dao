import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"
import { Japanese } from "flatpickr/dist/l10n/ja.js" // 日本語データをインポート

// Connects to data-controller="datepicker"
export default class extends Controller {
  connect() {
    flatpickr(this.element, {
      locale: Japanese,    // 日本語化
      dateFormat: "Y/m/d", // yyyy/mm/dd 形式に指定
      allowInput: true     // 手入力も許可する場合（任意）
    })
  }
}
