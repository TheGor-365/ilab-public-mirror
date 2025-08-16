import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import * as bootstrap from "bootstrap"
import "channels"
import '../packs/application.scss'
import "@fortawesome/fontawesome-free/css/all.css"
import "trix"
import "@rails/actiontext"
import "moment"
import "daterangepicker"
import "@hotwired/turbo-rails"
import "controllers";

window.bootstrap = bootstrap
window.jQuery = $;
window.$ = $;
global.toastr = require("toastr")

Rails.start()
ActiveStorage.start()


// === DESKTOP NAVIGATION AND CATEGORY HIGHLIGHT ===
let manualClick = false;

document.addEventListener('turbo:load', () => {
  const sections = document.querySelectorAll('.category-heading');
  const navLinks = document.querySelectorAll('.store-nav-link');
  const stickyHeaderText = document.getElementById('sticky-header-text');

  if (sections.length === 0 || navLinks.length === 0 || !stickyHeaderText) return;

  const originalHeaderText = stickyHeaderText.innerHTML;

  const observer = new IntersectionObserver((entries) => {
    if (manualClick) return;

    let topVisibleEntry = null;
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        if (!topVisibleEntry || entry.boundingClientRect.top < topVisibleEntry.boundingClientRect.top) {
          topVisibleEntry = entry;
        }
      }
    });

    if (topVisibleEntry) {
      const id = topVisibleEntry.target.getAttribute('id');
      const link = document.querySelector(`.store-nav-link[href="#${id}"]`);
      navLinks.forEach(l => l.classList.remove('active'));
      if (link) link.classList.add('active');
      stickyHeaderText.innerHTML = topVisibleEntry.target.textContent;
    } else if (window.scrollY < 200) {
      stickyHeaderText.innerHTML = originalHeaderText;
      navLinks.forEach(l => l.classList.remove('active'));
    }
  }, {
    rootMargin: `-120px 0px 0px 0px`,
    threshold: 0.5
  });

  sections.forEach(section => observer.observe(section));

  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      manualClick = true;
      const targetId = link.getAttribute('href').replace('#', '');
      const targetHeading = document.getElementById(targetId);

      if (targetHeading) {
        window.scrollTo({
          top: targetHeading.offsetTop - 100,
          behavior: 'smooth'
        });

        stickyHeaderText.innerHTML = targetHeading.textContent;
        navLinks.forEach(l => l.classList.remove('active'));
        link.classList.add('active');

        setTimeout(() => { manualClick = false; }, 600);
      }
    });
  });
});

document.addEventListener('turbo:load', () => {
  document.querySelectorAll('.store-nav-link').forEach(link => {
    link.addEventListener('click', () => {
      const offcanvas = document.querySelector('#storeOffcanvasNav');
      if (offcanvas && bootstrap && bootstrap.Offcanvas) {
        const instance = bootstrap.Offcanvas.getInstance(offcanvas);
        if (instance) instance.hide();
      }
    });
  });
});
