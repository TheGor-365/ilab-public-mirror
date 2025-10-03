// Мобилка: по клику "Открыть" показываем модалку и грузим /defects/:id в <turbo-frame id="defect_modal">
(function () {
  function openModalAndLoad(link) {
    const href = link.getAttribute('href'); if (!href) return;
    const modalEl = document.getElementById('defectDetailsModal');
    const frameEl = document.getElementById('defect_modal');
    if (!modalEl || !frameEl) return;

    frameEl.innerHTML = '<div class="text-center text-muted py-5">Загрузка…</div>';
    const modal = window.bootstrap?.Modal.getOrCreateInstance(modalEl);
    modal?.show();

    setTimeout(() => {
      if (window.Turbo?.visit) {
        Turbo.visit(href, { frame: 'defect_modal' });
      }
    }, 30);
  }

  function onClick(e) {
    const link = e.target.closest('a[data-defect-open="1"]');
    if (!link) return;
    e.preventDefault();
    openModalAndLoad(link);
  }

  document.addEventListener('click', onClick, false);
})();
