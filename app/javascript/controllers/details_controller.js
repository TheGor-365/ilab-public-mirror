// Показывает первые N элементов списка, остальное — по клику
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.listTargets.forEach((ul) => this.sliceList(ul))
  }

  toggleMore(event) {
    const card = event.currentTarget.closest(".accordion-body")
    const ul = card.querySelector("[data-details-target='list']")
    if (!ul) return

    const hidden = ul.querySelectorAll("li.d-none")
    hidden.forEach(li => li.classList.remove("d-none"))
    event.currentTarget.remove()
  }

  sliceList(ul) {
    const initial = parseInt(ul.dataset.initial || "10", 10)
    const items = ul.querySelectorAll("li")
    items.forEach((li, idx) => {
      if (idx >= initial) li.classList.add("d-none")
    })
  }
}
