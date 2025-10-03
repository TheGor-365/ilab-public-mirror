import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    sourceUrl: String, // /products/catalog_tree
    phonesUrl: String  // /products/catalog_phones
  };

  static targets = [
    "family", "phoneInput", "phoneList", "phonePanel", "phoneId", "generationId",
    "storage", "color", "sku", "nameInput",
    "skuBadge", "genBadge", "phoneBadge", "skuText",
    "defects", "repairs", "mods", "spares",
    "defectsCount", "repairsCount", "modsCount", "sparesCount",
    "description", "presets"
  ];

  connect() {
    this.labelsIndex = new Map();
    this._nameWasManuallyTyped = false;

    // --- submit guard: дождаться refresh и не дать опубликовать без SKU ---
    this._submittedOnce = false;
    this._form = this.element.closest("form");
    if (this._form) {
      this._onSubmit = this._onSubmit.bind(this);
      this._form.addEventListener("submit", this._onSubmit, { capture: true });
    }
  }

  disconnect() {
    if (this._form && this._onSubmit) {
      this._form.removeEventListener("submit", this._onSubmit, { capture: true });
    }
  }

  async _onSubmit(e) {
    // чтобы успеть подтянуть SKU после последнего выбора
    e.preventDefault();

    await this._refreshTree();

    // если пытаются НЕ draft и SKU пуст — стоп
    const stateEl = this._form.querySelector("#product_state");
    const state = stateEl?.value || "draft";
    if (state !== "draft" && !this.skuTarget.value) {
      alert("Выберите память и цвет — SKU не найден. Нельзя опубликовать товар без SKU.");
      return;
    }

    // избегаем рекурсии
    if (this._submittedOnce) return;
    this._submittedOnce = true;
    this._form.submit();
  }

  // === Семейство
  async onFamilyChange() {
    const family = this.familyTarget.value || "";
    this._clearPhoneSelection();
    this._clearSku();
    this._renderPanelPlaceholder();

    if (!family) return;

    const url = new URL(this.phonesUrlValue, window.location.origin);
    url.searchParams.set("family", family);
    url.searchParams.set("all", "true");
    const data = await fetch(url.toString(), { headers: { "Accept": "application/json" } }).then(r => r.json());

    this._fillDatalist(data.phones);
    this._fillPhonePanel(data.phones);
  }

  // === Поиск в даталисте
  async onPhoneQuery() {
    const q = (this.phoneInputTarget.value || "").trim();
    const family = this.familyTarget.value || "";

    if (q.length < 2 && !family) return;

    const url = new URL(this.phonesUrlValue, window.location.origin);
    if (family) url.searchParams.set("family", family);
    if (q)      url.searchParams.set("q", q);
    const data = await fetch(url.toString(), { headers: { "Accept": "application/json" } }).then(r => r.json());
    this._fillDatalist(data.phones);
  }

  // === Выбор из даталиста
  async onPhoneChosen() {
    const label = (this.phoneInputTarget.value || "").trim();
    if (!label) return;

    const rec = this.labelsIndex.get(label);
    if (!rec) return;
    await this._selectPhone(rec);
  }

  // === Смена памяти/цвета
  async onSkuFieldChange() {
    await this._refreshTree();
  }

  // === Ввод имени вручную
  onNameTyped() {
    this._nameWasManuallyTyped = true;
  }

  // === Добавление пресета текста в описание
  applyTextPreset(event) {
    const phrase = event.currentTarget.dataset.preset || "";
    if (!phrase) return;

    const ta = this.descriptionTarget;
    const current = (ta.value || "").trim();

    if (current.includes(phrase)) return;

    ta.value = (current ? current + (current.endsWith(".") ? " " : ". ") : "") + phrase;
    ta.dispatchEvent(new Event("input"));
    ta.focus();
  }

  // ---------------- internal ----------------

  async _selectPhone(rec) {
    this.phoneInputTarget.value    = rec.label || "";
    this.phoneIdTarget.value       = rec.id || "";
    this.generationIdTarget.value  = rec.generation_id || "";

    this._setText(this.phoneBadgeTargets, rec.label || "—");
    this._setText(this.genBadgeTargets, "");
    this._setText(this.skuBadgeTargets, "—");
    this._setText(this.skuTextTargets,  "—");

    await this._refreshTree();
  }

  async _refreshTree() {
    const genId   = (this.generationIdTarget.value || "").trim();
    const phoneId = (this.phoneIdTarget.value || "").trim();
    const storage = (this.storageTarget.value || "").trim();
    const color   = (this.colorTarget.value || "").trim();

    if (!genId && !phoneId) return;

    const url = new URL(this.sourceUrlValue, window.location.origin);
    if (genId)   url.searchParams.set("generation_id", genId);
    if (phoneId) url.searchParams.set("phone_id", phoneId);
    if (storage) url.searchParams.set("storage", storage);
    if (color)   url.searchParams.set("color", color);

    const data = await fetch(url.toString(), { headers: { "Accept": "application/json" } }).then(r => r.json());

    // селекты
    this._fillSelect(this.storageTarget, data.storages, storage);
    this._fillSelect(this.colorTarget,   data.colors,   color);

    // подписи
    if (data.generation_label) this._setText(this.genBadgeTargets,  data.generation_label);
    if (data.phone_label) {
      this._setText(this.phoneBadgeTargets, data.phone_label);
      if (!this._nameWasManuallyTyped) this.phoneInputTarget.value = data.phone_label;
    }

    // SKU
    if (data.sku_id) {
      this.skuTarget.value = data.sku_id;
      this._setText(this.skuBadgeTargets, data.sku_id);
    } else {
      this.skuTarget.value = "";
      this._setText(this.skuBadgeTargets, "—");
    }

    // Комплектация
    const skuText = [this.storageTarget.value, this.colorTarget.value].filter(Boolean).join(" ");
    this._setText(this.skuTextTargets, skuText || "—");

    // чекбоксы
    this._fillCheckboxes(this.defectsTarget, "product[defect_ids][]", data.defects || []);
    this._fillCheckboxes(this.repairsTarget, "product[repair_ids][]", data.repairs || []);
    this._fillCheckboxes(this.modsTarget,    "product[mod_ids][]",    data.mods    || []);
    this._fillCheckboxes(this.sparesTarget,  "product[spare_part_ids][]", data.spare_parts || []);

    this._injectQuickPresets(this.modsTarget,   ["Дисплей", "Камера", "Микрофон", "Динамик", "Разъём"]);
    this._injectQuickPresets(this.sparesTarget, ["Батарея", "Дисплей", "Камера", "Стекло", "Разъём"]);

    this._updateCounts();

    // автогенерация имени
    if (!this._nameWasManuallyTyped) {
      const parts = [];
      if (data.phone_label) parts.push(data.phone_label);
      if (this.storageTarget.value) parts.push(this.storageTarget.value);
      if (this.colorTarget.value)   parts.push(this.colorTarget.value);
      this.nameInputTarget.value = parts.join(" ").trim();
    }
  }

  _fillDatalist(phones) {
    this.labelsIndex.clear();
    this.phoneListTarget.innerHTML = "";
    (phones || []).forEach((p) => {
      const opt = document.createElement("option");
      opt.value = p.label;
      this.labelsIndex.set(p.label, p);
      this.phoneListTarget.appendChild(opt);
    });
  }

  _fillPhonePanel(phones) {
    const root = this.phonePanelTarget;
    root.innerHTML = "";
    if (!phones || phones.length === 0) {
      this._renderPanelPlaceholder();
      return;
    }

    const wrap = document.createElement("div");
    (phones || []).forEach((p) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "btn btn-sm btn-outline-secondary me-2 mb-2";
      btn.textContent = p.label;
      btn.addEventListener("click", () => this._selectPhone(p));
      wrap.appendChild(btn);
    });
    root.appendChild(wrap);
  }

  _renderPanelPlaceholder() {
    this.phonePanelTarget.innerHTML = `<div class="text-muted small">Выберите семейство — появится полный список моделей для клика.</div>`;
  }

  _fillSelect(selectEl, items, current) {
    const cur = current || "";
    const prev = selectEl.value;
    selectEl.innerHTML = "";
    const blank = document.createElement("option");
    blank.value = "";
    blank.textContent = "—";
    selectEl.appendChild(blank);

    (items || []).forEach((i) => {
      const opt = document.createElement("option");
      opt.value = i.id || i;
      opt.textContent = i.label || i;
      selectEl.appendChild(opt);
    });

    const want = cur || prev;
    if (want) selectEl.value = want;
  }

  _fillCheckboxes(container, name, items) {
    container.innerHTML = "";
    if (!items || items.length === 0) {
      container.innerHTML = `<div class="text-muted small">Нет данных для выбранной модели.</div>`;
      return;
    }

    const wrap = document.createElement("div");
    (items || []).forEach((it) => {
      const id = it.id;
      const label = it.label || `#${id}`;

      const div = document.createElement("div");
      div.className = "form-check form-check-inline me-3 mb-2";

      const input = document.createElement("input");
      input.type = "checkbox";
      input.className = "form-check-input";
      input.name = name;
      input.value = id;
      input.id = `${name}-${id}`;

      const lbl = document.createElement("label");
      lbl.className = "form-check-label";
      lbl.setAttribute("for", input.id);
      lbl.textContent = label;

      input.addEventListener("change", () => this._updateCounts());

      div.appendChild(input);
      div.appendChild(lbl);
      wrap.appendChild(div);
    });
    container.appendChild(wrap);
  }

  _injectQuickPresets(container, keywords = []) {
    if (!container) return;
    const bar = document.createElement("div");
    bar.className = "mb-2";
    keywords.forEach(k => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "btn btn-xs btn-outline-secondary me-2 mb-2";
      btn.textContent = k;
      btn.addEventListener("click", () => {
        container.querySelectorAll(".form-check-label").forEach(lbl => {
          if ((lbl.textContent || "").toLowerCase().includes(k.toLowerCase())) {
            const cb = container.querySelector(`#${lbl.getAttribute("for")}`);
            if (cb && !cb.checked) {
              cb.checked = true;
              cb.dispatchEvent(new Event("change"));
            }
          }
        });
      });
      bar.appendChild(btn);
    });
    container.prepend(bar);
  }

  _updateCounts() {
    const defects = this.defectsTarget.querySelectorAll('input[type="checkbox"]:checked').length;
    const repairs = this.repairsTarget.querySelectorAll('input[type="checkbox"]:checked').length;
    const mods    = this.modsTarget.querySelectorAll('input[type="checkbox"]:checked').length;
    const spares  = this.sparesTarget.querySelectorAll('input[type="checkbox"]:checked').length;

    this._setText(this.defectsCountTargets, String(defects));
    this._setText(this.repairsCountTargets, String(repairs));
    this._setText(this.modsCountTargets,    String(mods));
    this._setText(this.sparesCountTargets,  String(spares));
  }

  _clearPhoneSelection() {
    this.phoneInputTarget.value = "";
    this.phoneIdTarget.value = "";
    this.generationIdTarget.value = "";
    this._setText(this.phoneBadgeTargets, "—");
    this._setText(this.genBadgeTargets,   "—");
  }

  _clearSku() {
    this.storageTarget.innerHTML = `<option value="">—</option>`;
    this.colorTarget.innerHTML   = `<option value="">—</option>`;
    this.skuTarget.value = "";
    this._setText(this.skuBadgeTargets, "—");
    this._setText(this.skuTextTargets,  "—");
    this.defectsTarget.innerHTML = `<div class="text-muted small">Выберите семейство и модель — появятся варианты.</div>`;
    this.repairsTarget.innerHTML = `<div class="text-muted small">Выберите семейство и модель — появятся варианты.</div>`;
    this.modsTarget.innerHTML    = `<div class="text-muted small">Выберите семейство и модель — появятся варианты.</div>`;
    this.sparesTarget.innerHTML  = `<div class="text-muted small">Выберите семейство и модель — появятся варианты.</div>`;
    this._updateCounts();
  }

  _setText(elems, text) {
    (Array.isArray(elems) ? elems : [elems]).forEach(el => {
      if (el) el.textContent = text;
    });
  }
}
