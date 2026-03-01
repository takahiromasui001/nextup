import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    // 3秒後にフェードアウト開始
    this.timeout = setTimeout(() => {
      // フェードアウト完了時に要素を削除（once: true で1回だけ発火）
      this.element.addEventListener('transitionend', () => this.element.remove(), { once: true });
      // opacity の変化を 0.3秒かけてアニメーションさせる宣言
      this.element.style.transition = 'opacity 0.3s ease-out';
      // opacity を 0 にすることで上記 transition によるフェードアウトが開始
      this.element.style.opacity = '0';
    }, 3000);
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout);
  }
}
