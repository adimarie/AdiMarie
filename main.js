/* ===== THE ANIMIST APOTHECARY — main.js ===== */

// ── Header scroll behavior ──────────────────────────────────────────────────
const header = document.querySelector('.site-header');
if (header) {
  const onScroll = () => {
    header.classList.toggle('scrolled', window.scrollY > 50);
  };
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
}

// ── Active nav link ──────────────────────────────────────────────────────────
(function setActiveNav() {
  const path = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.main-nav a').forEach(link => {
    const href = link.getAttribute('href').split('#')[0];
    if (href === path) link.classList.add('nav-active');
  });
})();

// ── Accordion ────────────────────────────────────────────────────────────────
document.querySelectorAll('.accordion-header').forEach(header => {
  header.addEventListener('click', () => {
    const item = header.closest('.accordion-item');
    const isOpen = item.classList.contains('open');
    // Close all
    document.querySelectorAll('.accordion-item.open').forEach(el => el.classList.remove('open'));
    // Toggle clicked
    if (!isOpen) item.classList.add('open');
  });
});

// ── Smooth scroll for anchor links (offset for fixed header) ─────────────────
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', e => {
    const id = anchor.getAttribute('href').slice(1);
    if (!id) return;
    const target = document.getElementById(id);
    if (!target) return;
    e.preventDefault();
    const offset = 80;
    const top = target.getBoundingClientRect().top + window.scrollY - offset;
    window.scrollTo({ top, behavior: 'smooth' });
  });
});

// ── Fade-in on scroll (Intersection Observer) ────────────────────────────────
const fadeEls = document.querySelectorAll(
  '.section-story, .section-vision, .section-offerings, .section-practitioner, .section-process, .section-testimonial, .section-modalities, .section-cycle, .about-bio, .about-sections, .community-grid, .offering-detail, .offering-detail-sidebar'
);

if ('IntersectionObserver' in window && fadeEls.length) {
  fadeEls.forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(24px)';
    el.style.transition = 'opacity 0.7s ease, transform 0.7s ease';
  });

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.08 });

  fadeEls.forEach(el => observer.observe(el));
}

// ── Header .scrolled style injection ────────────────────────────────────────
(function injectScrolledStyle() {
  const style = document.createElement('style');
  style.textContent = `.site-header.scrolled { box-shadow: 0 2px 30px rgba(0,0,0,0.08); }`;
  document.head.appendChild(style);
})();
