/* ═════════════════════════════════════════════════════════════
   SIBYX — Interactions client
   Mobile nav, header on scroll, form, reveals au scroll
   ═════════════════════════════════════════════════════════════ */

(() => {
  'use strict';

  // ─── Année dynamique footer ──────────────────────────────
  const yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  // ─── Header : classe au scroll ───────────────────────────
  const header = document.querySelector('.site-header');
  let lastScroll = 0;

  const handleScroll = () => {
    const y = window.scrollY;
    header?.classList.toggle('is-scrolled', y > 24);
    lastScroll = y;
  };

  window.addEventListener('scroll', handleScroll, { passive: true });
  handleScroll();

  // ─── Navigation mobile ───────────────────────────────────
  const navToggle = document.querySelector('.nav-toggle');
  const navMobile = document.getElementById('mobile-nav');

  if (navToggle && navMobile) {
    const setMenuState = (open) => {
      navToggle.setAttribute('aria-expanded', String(open));
      navMobile.hidden = !open;
      navToggle.setAttribute(
        'aria-label',
        open ? 'Fermer le menu' : 'Ouvrir le menu'
      );
      // Empêcher le scroll quand le menu est ouvert sur mobile
      document.body.style.overflow = open ? 'hidden' : '';
    };

    navToggle.addEventListener('click', () => {
      const isOpen = navToggle.getAttribute('aria-expanded') === 'true';
      setMenuState(!isOpen);
    });

    // Fermer au clic sur un lien
    navMobile.querySelectorAll('a').forEach((link) => {
      link.addEventListener('click', () => setMenuState(false));
    });

    // Fermer avec Escape
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && navToggle.getAttribute('aria-expanded') === 'true') {
        setMenuState(false);
        navToggle.focus();
      }
    });

    // Si on repasse en desktop, fermer + restaurer le scroll
    const mqDesktop = window.matchMedia('(min-width: 769px)');
    mqDesktop.addEventListener('change', (e) => {
      if (e.matches) setMenuState(false);
    });
  }

  // ─── Reveals au scroll (IntersectionObserver) ────────────
  // Approche progressive enhancement :
  //  - On cache uniquement les éléments hors viewport au chargement
  //  - On les révèle au scroll
  //  - Safety net : tout est révélé après 2,5s, même si l'observer rate

  const revealTargets = document.querySelectorAll(
    '.service-card, .why-item, .approach-step, .testimonial-card, .stat'
  );

  const revealEl = (el) => {
    el.style.opacity = '1';
    el.style.transform = 'translateY(0)';
  };

  if ('IntersectionObserver' in window && revealTargets.length) {
    const viewportH = window.innerHeight;
    const observed = [];

    revealTargets.forEach((el, i) => {
      const rect = el.getBoundingClientRect();
      // Si l'élément est déjà visible (ou presque), on le laisse tel quel.
      if (rect.top < viewportH * 0.9) return;

      el.style.opacity = '0';
      el.style.transform = 'translateY(16px)';
      el.style.transition =
        'opacity 700ms cubic-bezier(.16, 1, .3, 1), transform 700ms cubic-bezier(.16, 1, .3, 1)';
      el.style.transitionDelay = `${(i % 4) * 80}ms`;
      observed.push(el);
    });

    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            revealEl(entry.target);
            io.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.12, rootMargin: '0px 0px -80px 0px' }
    );

    observed.forEach((el) => io.observe(el));

    // Safety net : si après 2,5s un élément n'a pas été révélé, on le force.
    // Évite les éléments invisibles en cas de bug d'observer ou de scroll rapide.
    setTimeout(() => {
      observed.forEach((el) => {
        if (parseFloat(getComputedStyle(el).opacity) < 1) revealEl(el);
      });
    }, 2500);
  }

  // ─── Formulaire contact ──────────────────────────────────
  const form = document.getElementById('contact-form');
  if (!form) return;

  const feedback = form.querySelector('.form-feedback');
  const submitBtn = form.querySelector('button[type="submit"]');
  const FALLBACK_EMAIL = 'mistercamara27@gmail.com';

  const showFeedback = (msg, type = 'success') => {
    if (!feedback) return;
    feedback.textContent = msg;
    feedback.classList.remove('is-success', 'is-error');
    feedback.classList.add(type === 'success' ? 'is-success' : 'is-error');
  };

  const validate = (data) => {
    if (!data.name || data.name.trim().length < 2)
      return 'Merci de renseigner votre nom.';
    if (!data.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email))
      return 'Merci de renseigner un email valide.';
    if (!data.service)
      return 'Merci de choisir un sujet.';
    if (!data.message || data.message.trim().length < 10)
      return 'Merci de détailler un peu votre demande (10 caractères minimum).';
    return null;
  };

  const resetButton = () => {
    submitBtn.disabled = false;
    submitBtn.innerHTML =
      'Envoyer le message <span class="btn-arrow" aria-hidden="true">→</span>';
  };

  const openMailto = (data) => {
    const subject = encodeURIComponent(`[SIBYX] Demande — ${data.service}`);
    const body = encodeURIComponent(
      `Nom : ${data.name}\n` +
      `Email : ${data.email}\n` +
      `Entreprise : ${data.organization || '—'}\n` +
      `Sujet : ${data.service}\n\n` +
      `Message :\n${data.message}\n`
    );
    window.location.href = `mailto:${FALLBACK_EMAIL}?subject=${subject}&body=${body}`;
  };

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const data = Object.fromEntries(new FormData(form).entries());
    const error = validate(data);

    if (error) {
      showFeedback(error, 'error');
      return;
    }

    submitBtn.disabled = true;
    submitBtn.textContent = 'Envoi…';

    const action = form.getAttribute('action') || '';
    // Si l'action Formspree n'est pas encore configurée (placeholder),
    // on bascule directement sur mailto.
    if (!action || action.includes('VOTRE_ID_FORMSPREE')) {
      openMailto(data);
      showFeedback(
        'Votre client de messagerie s’ouvre. Si rien ne se passe, écrivez-nous directement à ' + FALLBACK_EMAIL + '.',
        'success'
      );
      resetButton();
      return;
    }

    // Envoi normal vers Formspree
    try {
      const response = await fetch(action, {
        method: 'POST',
        headers: { 'Accept': 'application/json' },
        body: new FormData(form),
      });

      if (response.ok) {
        showFeedback(
          'Merci, votre message est bien parti. Nous revenons vers vous sous 48 h ouvrées.',
          'success'
        );
        form.reset();
      } else {
        // Réponse non-ok : on tente le mailto en dernier recours
        openMailto(data);
        showFeedback(
          'L’envoi a rencontré un souci. Votre client de messagerie va s’ouvrir comme alternative.',
          'error'
        );
      }
    } catch (err) {
      openMailto(data);
      showFeedback(
        'Connexion impossible. Votre client de messagerie va s’ouvrir comme alternative.',
        'error'
      );
    } finally {
      resetButton();
    }
  });
})();
