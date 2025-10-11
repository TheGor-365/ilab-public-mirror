// Навигация Store (десктоп/мобила) + якоря, без дерганий лейаута.
// Исправлено: повторные клики по "пилюлям" на мобиле гарантированно подгружают turbo_stream.
// Добавлен cache-busting & корректные Accept-заголовки.

(function () {
  // --- helpers ---
  function cssVar(name, fallback) {
    const raw = getComputedStyle(document.documentElement).getPropertyValue(name) || '';
    const n = parseInt(raw, 10);
    return isNaN(n) ? fallback : n;
  }

  function isDesktop() {
    return window.matchMedia('(min-width: 992px)').matches;
  }

  function getOffsetY() {
    return isDesktop() ? cssVar('--main-navbar-height', 67) : cssVar('--mobile-navbar-height', 56);
  }

  function scrollToWithOffset(target) {
    const y = target.getBoundingClientRect().top + window.pageYOffset - getOffsetY();
    window.scrollTo({ top: y, behavior: 'smooth' });
  }

  function findOffcanvas(targetLink) {
    const sel = targetLink.getAttribute('data-bs-target') || '#storeOffcanvasNav';
    const el = document.querySelector(sel);
    if (!el || !window.bootstrap) return null;
    return window.bootstrap.Offcanvas.getInstance(el) || new window.bootstrap.Offcanvas(el);
  }

  function setActivePill(link) {
    const wrap = link.closest('.store-nav__families');
    if (!wrap) return;
    wrap.querySelectorAll('.pill.active').forEach(a => a.classList.remove('active'));
    link.classList.add('active');
  }

  // true => stream применён, false => нужен fallback
  function ajaxTurboStream(url) {
    return fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html, text/html;q=0.9,*/*;q=0.8',
        'X-Requested-With': 'XMLHttpRequest',
        'Turbo-Frame': '' // на всякий случай не указывать конкретный фрейм
      },
      cache: 'no-store',
      credentials: 'same-origin',
    })
      .then(res => {
        if (!res.ok) return false;
        const ct = (res.headers.get('Content-Type') || '').toLowerCase();

        return res.text().then(html => {
          const isStream = ct.includes('turbo-stream') || html.includes('<turbo-stream');
          if (isStream && window.Turbo && Turbo.renderStreamMessage) {
            Turbo.renderStreamMessage(html);
            return true;
          }
          return false;
        });
      })
      .catch(() => false);
  }

  function withTurboStreamParam(href) {
    if (!href) return href;
    const sep = href.includes('?') ? '&' : '?';
    // cache-busting, чтобы второй/третий клик не наталкивался на кэш
    return `${href}${sep}format=turbo_stream&_ts=${Date.now()}`;
  }

  // --- events ---
  function onDocClick(e) {
    const link = e.target.closest('a');
    if (!link) return;

    // 1) Пилюли семейств
    if (link.matches('a[data-role="family"]')) {
      const href = link.getAttribute('href');
      if (!href) return;

      if (isDesktop()) {
        // На десктопе делаем обычную Turbo-навигацию
        if (window.Turbo) {
          e.preventDefault();
          Turbo.visit(href);
        }
      } else {
        // На мобиле: ajax turbo_stream + cache-busting
        e.preventDefault();
        setActivePill(link);

        const url = withTurboStreamParam(href);
        try { history.pushState({}, '', href); } catch (_) {}

        ajaxTurboStream(url).then(ok => {
          if (!ok && window.Turbo) Turbo.visit(href);
        });
      }
      return;
    }

    // 2) Якоря (раздел/товар)
    const selector = link.getAttribute('data-store-anchor');
    if (selector) {
      const target = document.querySelector(selector);
      if (!target) return;

      const isProduct = link.getAttribute('data-role') === 'product';
      const oc = findOffcanvas(link);

      e.preventDefault();

      const doScroll = () => {
        setTimeout(() => {
          scrollToWithOffset(target);
          try { history.replaceState({}, '', selector); } catch (_) {}
        }, 40);
      };

      if (!isDesktop() && isProduct && oc) {
        const ocEl = oc._element;
        const handler = () => {
          ocEl.removeEventListener('hidden.bs.offcanvas', handler);
          doScroll();
        };
        ocEl.addEventListener('hidden.bs.offcanvas', handler);
        oc.hide();
      } else {
        doScroll();
      }
    }
  }

  // Делегирование — живёт через Turbo-перерисовки
  document.addEventListener('click', onDocClick, false);
})();
