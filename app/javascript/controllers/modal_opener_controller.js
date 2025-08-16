import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  connect() {
    // Открываем модалку автоматически на ширине < 768px
    if (window.innerWidth < 768) {
      const modalEl = document.getElementById("productDetailsModal")
      if (!modalEl) return
      const modal = bootstrap.Modal.getOrCreateInstance(modalEl)
      modal.show()
    }
  }
}
