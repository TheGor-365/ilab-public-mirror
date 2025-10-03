(function () {
  // === 1) Открытие модалки и подгрузка в Turbo Frame (твой существующий код)
  function openModalAndLoad(link) {
    const href = link.getAttribute('href'); if (!href) return;
    const modalEl = document.getElementById('sparePartDetailsModal');
    const frameEl = document.getElementById('spare_part_modal');
    if (!modalEl || !frameEl) return;

    frameEl.innerHTML = '<div class="text-center text-muted py-5">Загрузка…</div>';
    const modal = window.bootstrap?.Modal.getOrCreateInstance(modalEl);
    modal?.show();

    setTimeout(() => {
      if (window.Turbo?.visit) {
        Turbo.visit(href, { frame: 'spare_part_modal' });
      }
    }, 30);
  }

  function onClick(e) {
    const link = e.target.closest('a[data-spare-part-open="1"]');
    if (!link) return;
    e.preventDefault();
    openModalAndLoad(link);
  }

  document.addEventListener('click', onClick, false);

  // === 2) Фильтр рубрик (мой код)
  function bindRubricFilter(scopeSel, listSel) {
    const scope = document.querySelector(scopeSel);
    const list = document.querySelector(listSel);
    if (!scope || !list) return;

    scope.addEventListener('click', (e) => {
      const btn = e.target.closest('[data-rubric]');
      if (!btn) return;

      const value = btn.getAttribute('data-rubric');

      if (value === 'all') {
        scope.querySelectorAll('[data-rubric].active').forEach(x => x.classList.remove('active'));
        btn.classList.add('active');
        list.querySelectorAll('[data-rubric]').forEach(li => li.classList.remove('d-none'));
        return;
      }

      scope.querySelectorAll('[data-rubric].active').forEach(x => { if (x !== btn) x.classList.remove('active'); });
      btn.classList.add('active');

      const rubric = btn.getAttribute('data-rubric');
      list.querySelectorAll('[data-rubric]').forEach(li => {
        li.classList.toggle('d-none', li.getAttribute('data-rubric') !== rubric);
      });
    });
  }

  function init() {
    bindRubricFilter('#spares-rubrics', '#spares-list');
  }

  document.addEventListener('turbo:load', init);
})();
