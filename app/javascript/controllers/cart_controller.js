import { Controller } from "@hotwired/stimulus"

// Управляет отступом от навбара и плюс/минус количеством.
export default class extends Controller {
  static targets = ["qtyInput"]

  connect() {
    this.computeOffset()
    window.addEventListener("resize", this.computeOffset)
    document.addEventListener("turbo:load", this.computeOffset)
    document.addEventListener("shown.bs.offcanvas", this.computeOffset)
    document.addEventListener("hidden.bs.offcanvas", this.computeOffset)

    // Кнопки +/- количества (делегирование)
    document.addEventListener("click", this.onQtyClick, false)
  }

  disconnect() {
    window.removeEventListener("resize", this.computeOffset)
    document.removeEventListener("turbo:load", this.computeOffset)
    document.removeEventListener("shown.bs.offcanvas", this.computeOffset)
    document.removeEventListener("hidden.bs.offcanvas", this.computeOffset)
    document.removeEventListener("click", this.onQtyClick, false)
  }

  computeOffset = () => {
    const nav = document.querySelector('.navbar.fixed-top')
    const navH = nav ? Math.round(nav.getBoundingClientRect().height) : 67
    document.documentElement.style.setProperty('--ui-offset', navH + 'px')
    document.documentElement.style.setProperty('--main-navbar-height', navH + 'px')
  }

  onQtyClick = (e) => {
    const dec = e.target.closest('[data-cart-qty-dec]')
    const inc = e.target.closest('[data-cart-qty-inc]')
    if (!dec && !inc) return

    const id = (dec || inc).getAttribute('data-item-id')
    const input = document.querySelector(`input[data-item-id="${id}"]`)
    if (!input) return
    let v = parseInt(input.value || '1', 10)
    if (isNaN(v) || v < 1) v = 1
    v += (inc ? 1 : -1)
    if (v < 1) v = 1
    input.value = v
    input.dispatchEvent(new Event('change', { bubbles: true }))
  }
}
