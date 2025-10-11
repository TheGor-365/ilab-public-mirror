import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["root", "query", "total"];

  filter() {
    const q = (this.queryTarget.value || "").trim().toLowerCase();

    const items = this.element.querySelectorAll(".js-item");
    let visibleCount = 0;

    items.forEach((li) => {
      const name = li.dataset.name || li.textContent.toLowerCase();
      const match = !q || name.includes(q);
      li.classList.toggle("d-none", !match);
      if (match) visibleCount++;
    });

    // пересчитываем секции
    this.element.querySelectorAll("[data-section]").forEach((section) => {
      const visibleInSection = section.querySelectorAll(".js-item:not(.d-none)").length;
      section.classList.toggle("d-none", visibleInSection === 0);
      const badge = section.querySelector("[data-section-count]");
      if (badge) badge.textContent = visibleInSection;
    });

    if (this.hasTotalTarget) this.totalTarget.textContent = visibleCount;
  }
}
