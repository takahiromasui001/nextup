import { Controller } from '@hotwired/stimulus';
import { slideOutVertical } from 'helpers/card_animation';

export default class extends Controller {
  snooze(event) {
    this.element.classList.add('hidden');
    slideOutVertical(this._cardElement(), 1);
  }

  cancel(event) {
    event.stopPropagation();
    this.element.classList.add('hidden');
  }

  _cardElement() {
    return this.element.closest('[data-controller="swipe"]');
  }
}
