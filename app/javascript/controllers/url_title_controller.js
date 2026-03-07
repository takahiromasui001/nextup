import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['url', 'title', 'loading']

  paste(event) {
    const pasted = (event.clipboardData || window.clipboardData).getData('text')
    if (!this.#isUrl(pasted)) return

    // pasteイベント時点ではまだ値が反映されていないため非同期で処理
    setTimeout(() => this.#fetchTitle(pasted), 0)
  }

  #isUrl(value) {
    try {
      const url = new URL(value)
      return url.protocol === 'http:' || url.protocol === 'https:'
    } catch {
      return false
    }
  }

  async #fetchTitle(url) {
    this.loadingTarget.classList.remove('hidden')
    try {
      const res = await fetch(`/title?url=${encodeURIComponent(url)}`)
      if (!res.ok) return

      const { title } = await res.json()
      if (title && this.titleTarget.value === '') {
        this.titleTarget.value = title
      }
    } catch {
      // 取得失敗時は何もしない
    } finally {
      this.loadingTarget.classList.add('hidden')
    }
  }
}
