import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["counter"]

  connect() {
    if ("IntersectionObserver" in window) {
      const io = new IntersectionObserver((entries) => {
        entries.forEach(e => {
          if (e.isIntersecting) {
            this.animateCounters()
            io.disconnect()
          }
        })
      }, { threshold: 0.4 })
      io.observe(this.element)
    } else {
      this.animateCounters()
    }
  }

  animateCounters() {
    this.counterTargets.forEach(el => {
      const to = parseFloat(el.dataset.to || "0")
      const dec = el.dataset.decimals ? parseInt(el.dataset.decimals) : (Number.isInteger(to) ? 0 : 0)
      const dur = parseInt(el.dataset.duration || "1000")
      const start = performance.now()

      const step = (tNow) => {
        const t = Math.min(1, (tNow - start) / dur)
        const eased = 0.2 + 0.8 * t * t
        const val = to * eased
        el.textContent = dec ? val.toFixed(dec) : Math.round(val).toLocaleString()
        if (t < 1) requestAnimationFrame(step)
        else el.textContent = dec ? to.toFixed(dec) : Math.round(to).toLocaleString()
      }
      requestAnimationFrame(step)
    })
  }
}
