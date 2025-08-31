// Единая навигация по якорям: оффканвас (мобилка) + десктоп
document.addEventListener('turbo:load', () => {
  const links = document.querySelectorAll('[data-store-anchor]');
  if (!links.length) return;

  function getOffsetY() {
    // читаем CSS var, fallback на 88
    const cs = getComputedStyle(document.documentElement);
    const raw = cs.getPropertyValue('--main-navbar-height') || '88px';
    const h = parseInt(raw, 10);
    // небольшой запас, чтобы заголовок был "чуть ниже" верхнего края
    return (isNaN(h) ? 88 : h) + 18;
  }

  function scrollToWithOffset(target) {
    const y = target.getBoundingClientRect().top + window.pageYOffset - getOffsetY();
    window.scrollTo({ top: y, behavior: 'smooth' });
  }

  links.forEach(link => {
    link.addEventListener('click', (e) => {
      const selector = link.getAttribute('data-store-anchor');
      if (!selector) return;
      const target = document.querySelector(selector);
      if (!target) return;

      const isOffcanvas = link.getAttribute('data-offcanvas') === 'true';
      const targetOffcanvas = link.getAttribute('data-bs-target');

      if (isOffcanvas && targetOffcanvas && window.bootstrap) {
        e.preventDefault();
        const ocEl = document.querySelector(targetOffcanvas);
        const oc = window.bootstrap.Offcanvas.getInstance(ocEl) || new window.bootstrap.Offcanvas(ocEl);

        const doScroll = () => {
          setTimeout(() => {
            scrollToWithOffset(target);
            history.replaceState(null, '', selector);
          }, 60);
        };

        ocEl.addEventListener('hidden.bs.offcanvas', function handler() {
          ocEl.removeEventListener('hidden.bs.offcanvas', handler);
          doScroll();
        });

        oc.hide();
      } else {
        // Десктоп — берём управление, чтобы сделать офсет
        e.preventDefault();
        scrollToWithOffset(target);
        history.replaceState(null, '', selector);
      }
    });
  });
});
