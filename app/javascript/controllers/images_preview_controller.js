import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["avatar","imagesWrap"]

  avatar(e) {
    const file = e.target.files?.[0]
    if (!file) return
    const img = this.avatarTarget
    const r = new FileReader()
    r.onload = ev => { img.src = ev.target.result; img.classList.remove("d-none") }
    r.readAsDataURL(file)
  }

  images(e) {
    this.imagesWrapTarget.innerHTML = ""
    Array.from(e.target.files || []).forEach(f => {
      const r = new FileReader()
      r.onload = ev => {
        const col = document.createElement("div")
        col.className = "col-4 col-md-2"
        const img = document.createElement("img")
        img.className = "img-fluid rounded shadow-sm"
        img.src = ev.target.result
        col.appendChild(img)
        this.imagesWrapTarget.appendChild(col)
      }
      r.readAsDataURL(f)
    })
  }
}
