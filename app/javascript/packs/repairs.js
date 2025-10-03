// Мобилка: по клику "Открыть" показываем модалку и грузим /repairs/:id в <turbo-frame id="repair_modal">
(function () {
  function openModalAndLoad(link) {
    const href = link.getAttribute('href');
    if (!href) return;

    const modalEl = document.getElementById('repairDetailsModal');
    const frameEl = document.getElementById('repair_modal');
    if (!modalEl || !frameEl) return;

    // Плейсхолдер перед запросом
    frameEl.innerHTML = '<div class="text-center text-muted py-5">Загрузка…</div>';

    const modal = window.bootstrap && window.bootstrap.Modal
      ? window.bootstrap.Modal.getOrCreateInstance(modalEl)
      : null;

    if (modal) modal.show();

    // Небольшая задержка — чтобы модалка успела смонтироваться
    setTimeout(() => {
      if (window.Turbo && Turbo.visit) {
        Turbo.visit(href, { frame: 'repair_modal' });
      } else {
        // Фоллбек без Turbo (маловероятно)
        fetch(href, {
          headers: {
            'Turbo-Frame': 'repair_modal',
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'text/vnd.turbo-stream.html, text/html;q=0.9,*/*;q=0.8'
          },
          credentials: 'same-origin'
        })
          .then(r => r.text())
          .then(html => {
            // если вернулся turbo-frame — заменим его, иначе просто вставим
            if (html.includes('<turbo-frame')) {
              const tmp = document.createElement('div');
              tmp.innerHTML = html;
              const newFrame = tmp.querySelector('turbo-frame#repair_modal');
              if (newFrame) frameEl.replaceWith(newFrame);
              else frameEl.innerHTML = html;
            } else if (window.Turbo && Turbo.renderStreamMessage && html.includes('<turbo-stream')) {
              Turbo.renderStreamMessage(html);
            } else {
              frameEl.innerHTML = html;
            }
          })
          .catch(() => {});
      }
    }, 30);
  }

  function onClick(e) {
    const link = e.target.closest('a[data-repair-open="1"]');
    if (!link) return;
    e.preventDefault();
    openModalAndLoad(link);
  }

  document.addEventListener('click', onClick, false);
})();
