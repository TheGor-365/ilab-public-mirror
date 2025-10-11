import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["family", "generation", "storage", "color", "phoneId", "modelId", "displayName"]

  connect() {
    // подгрузим список семейств (на будущее)
    fetch("/admin/catalog/families")
      .then(r => r.json())
      .then(({ families }) => {
        // если select уже предзаполнен — пропустим
        if (this.familyTarget.options.length <= 1) {
          families.forEach(f => this.addOption(this.familyTarget, f, f))
        }
      })
      .catch(() => {})
  }

  onFamilyChange() {
    const family = this.familyTarget.value
    this.clearSelect(this.generationTarget)
    this.clearSelect(this.storageTarget)
    this.clearSelect(this.colorTarget)
    this.phoneIdTarget.value = ""
    this.modelIdTarget.value = ""
    if (!family) return

    fetch(`/admin/catalog/generations?family=${encodeURIComponent(family)}`)
      .then(r => r.json())
      .then(({ generations }) => {
        generations.forEach(g => this.addOption(this.generationTarget, g.title, g.id))
      })
  }

  onGenerationChange() {
    const genId = this.generationTarget.value
    this.clearSelect(this.storageTarget)
    this.clearSelect(this.colorTarget)
    this.phoneIdTarget.value = ""
    this.modelIdTarget.value = ""
    if (!genId) return

    fetch(`/admin/catalog/options?generation_id=${encodeURIComponent(genId)}`)
      .then(r => r.json())
      .then(({ storage, colors, phone_id, model_id }) => {
        storage.forEach(s => this.addOption(this.storageTarget, s, s))
        colors.forEach(c => this.addOption(this.colorTarget, c, c))
        if (phone_id) this.phoneIdTarget.value = phone_id
        if (model_id) this.modelIdTarget.value = model_id
      })
  }

  updateDisplayName() {
    const genText = this.generationTarget.options[this.generationTarget.selectedIndex]?.text || ""
    const storage = this.storageTarget.value || ""
    const color   = this.colorTarget.value || ""
    const name = [genText, storage, color].filter(Boolean).join(" ")
    if (this.hasDisplayNameTarget) this.displayNameTarget.value = name
  }

  addOption(select, label, value) {
    const opt = document.createElement("option")
    opt.textContent = label
    opt.value = value
    select.appendChild(opt)
  }

  clearSelect(select) {
    while (select.options.length > 1) select.remove(1)
  }
}
