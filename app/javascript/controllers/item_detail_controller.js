import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['detail', 'icon']

  toggle() {
    this.detailTarget.classList.toggle('hidden')
    this.iconTarget.classList.toggle('rotate-180')
  }
}
