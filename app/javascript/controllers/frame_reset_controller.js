import { Controller } from "@hotwired/stimulus"

/*
 * frame-reset: локально откатывает Turbo Frame к плейсхолдеру без запроса.
 * values:
 *  - frameId: id фрейма, который надо очистить
 *  - placeholder: опционально HTML-плейсхолдер, иначе дефолт (для repairs)
 */
export default class extends Controller {
  static values = { frameId: String, placeholder: String }

  toPlaceholder(event) {
    event.preventDefault()
    const id = this.frameIdValue || this.element.getAttribute("data-frame-id")
    if (!id) return
    const frame = document.getElementById(id)
    if (!frame) return

    const html = this.hasPlaceholderValue
      ? this.placeholderValue
      : `
        <div class="text-center text-muted py-5">
          <div class="mb-2">Выберите ремонт слева, чтобы увидеть детали.</div>
          <small>Поддерживаются Turbo-frames, без перезагрузки страницы.</small>
        </div>
      `
    frame.innerHTML = html
  }

  closeModal(event) {
    event.preventDefault()
    const modal = document.querySelector(".modal.show")
    if (!modal || !window.bootstrap) return
    window.bootstrap.Modal.getOrCreateInstance(modal).hide()
  }
}
