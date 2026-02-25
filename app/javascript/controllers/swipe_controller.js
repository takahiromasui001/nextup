import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    position: Number,
    total: Number,
    nextUrl: String,
    prevUrl: String,
  };
  static targets = ['upLabel', 'downLabel'];

  connect() {
    this.startX = 0;
    this.startY = 0;
    this.currentX = 0;
    this.currentY = 0;
    this.dragging = false;
    this.threshold = 80;

    const el = this.element;
    el.addEventListener('pointerdown', this._onPointerDown.bind(this));
    el.addEventListener('pointermove', this._onPointerMove.bind(this));
    el.addEventListener('pointerup', this._onPointerUp.bind(this));
    el.addEventListener('pointercancel', this._onPointerUp.bind(this));
  }

  _onPointerDown(e) {
    this.element.setPointerCapture(e.pointerId);
    this.startX = e.clientX;
    this.startY = e.clientY;
    this.currentX = 0;
    this.currentY = 0;
    this.dragging = true;
    this.element.style.transition = 'none';
  }

  _onPointerMove(e) {
    if (!this.dragging) return;
    e.preventDefault();

    // 開始位置からのドラッグ量を算出
    this.currentX = e.clientX - this.startX;
    this.currentY = e.clientY - this.startY;

    // カードを移動+傾ける（横100pxドラッグで10度回転）
    const rotate = this.currentX * 0.1;
    this.element.style.transform = `translate(${this.currentX}px, ${this.currentY}px) rotate(${rotate}deg)`;

    // 縦横それぞれのドラッグ距離（方向を無視した絶対値）
    const absX = Math.abs(this.currentX);
    const absY = Math.abs(this.currentY);

    // 縦方向のドラッグが優勢な場合、方向ラベルを表示する
    if (absY > absX) {
      // ドラッグ量に応じて徐々に濃くする（閾値で最大1.0）
      const opacity = Math.min(absY / this.threshold, 1);
      // 上ドラッグ → Pin Now / 下ドラッグ → Snooze / Done
      if (this.currentY < 0 && this.hasUpLabelTarget) {
        this.upLabelTarget.style.opacity = opacity;
      } else if (this.currentY > 0 && this.hasDownLabelTarget) {
        this.downLabelTarget.style.opacity = opacity;
      }
    } else {
      // 横方向が優勢なら方向ラベルを非表示に戻す
      if (this.hasUpLabelTarget) this.upLabelTarget.style.opacity = 0;
      if (this.hasDownLabelTarget) this.downLabelTarget.style.opacity = 0;
    }
  }

  _onPointerUp() {
    if (!this.dragging) return;
    this.dragging = false;

    const absX = Math.abs(this.currentX);
    const absY = Math.abs(this.currentY);

    if (absX > absY && absX > this.threshold) {
      const direction = this.currentX < 0 ? -1 : 1;
      const url = this.currentX < 0 ? this.nextUrlValue : this.prevUrlValue;
      if (url) {
        this._slideOut(direction, url);
        return;
      }
    }

    this._snapBack();
  }

  _slideOut(direction, url) {
    // カードを画面外へスライドさせる
    const offscreen = direction * window.innerWidth;
    this.element.style.transition = 'transform 0.3s ease-out';
    this.element.style.transform = `translate(${offscreen}px, 0) rotate(${direction * 30}deg)`;

    // アニメーション後に次/前のカードを Turbo Frame で読み込む
    setTimeout(() => {
      const frame = document.querySelector('turbo-frame#deck_card');
      if (frame) {
        frame.src = url;
      }
    }, 200);
  }

  _snapBack() {
    this.element.style.transition = 'transform 0.3s ease-out';
    this.element.style.transform = 'translate(0, 0) rotate(0deg)';
    if (this.hasUpLabelTarget) this.upLabelTarget.style.opacity = 0;
    if (this.hasDownLabelTarget) this.downLabelTarget.style.opacity = 0;
  }
}
