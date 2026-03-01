// カードを横方向に画面外へスライドさせる
export function slideOutHorizontal(element, direction) {
  const offscreen = direction * window.innerWidth;
  element.style.transition = 'transform 0.3s ease-out';
  element.style.transform = `translate(${offscreen}px, 0) rotate(${direction * 30}deg)`;
}

// カードを縦方向に画面外へスライドさせる
export function slideOutVertical(element, direction) {
  const offscreen = direction * window.innerHeight;
  element.style.transition = 'transform 0.3s ease-out';
  element.style.transform = `translate(0, ${offscreen}px)`;
}

// カードを元の位置に戻す
export function snapBack(element) {
  element.style.transition = 'transform 0.3s ease-out';
  element.style.transform = 'translate(0, 0) rotate(0deg)';
}
