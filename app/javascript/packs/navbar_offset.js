// подсчёт отступа под fixed navbar и наш баннер
function recalcOffsets() {
  const navbar = document.querySelector('.navbar.fixed-top');
  const banner = document.querySelector('.page-banner');
  const navbarH = navbar ? navbar.getBoundingClientRect().height : 0;
  const bannerH = banner ? banner.getBoundingClientRect().height : 0;
  document.documentElement.style.setProperty('--navbar-offset', `${navbarH}px`);
  // если баннер есть — добавим паддинг body, чтобы контент не прятался под ним
  const pad = navbarH + bannerH;
  document.body.style.paddingTop = pad ? `${pad}px` : '';
}
['turbo:load', 'resize'].forEach(evt =>
  window.addEventListener(evt, recalcOffsets)
);
