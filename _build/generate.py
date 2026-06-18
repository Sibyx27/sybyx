#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Générateur statique SIBYX.
Produit :
  - methode/<slug>.html   (16 pages piliers, silo SEO maillé)
  - <service>.html         (3 pages services)
  - sitemap.xml            (régénéré avec toutes les URL)

Le contenu est rédigé à la main dans les structures ci-dessous : chaque page
a un texte unique (pas de contenu dupliqué). Le script ne fait qu'assembler.
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = "https://sybyx27.github.io/sibyx"

# ── Phases ───────────────────────────────────────────────────────────────
PHASES = {
    1: "Stratégie & validation",
    2: "Fondations",
    3: "Production & indexation",
    4: "Autorité & visibilité augmentée",
    5: "Industrialisation & pilotage",
}

# ── 16 piliers ───────────────────────────────────────────────────────────
# slug, num, phase, titre, lede, intro (2-3 phrases), items[(nom, explication)]
PILLARS = [
    ("idee", 1, 1, "Idée",
     "Trouver l’angle où la demande, le business et la concurrence s’alignent.",
     "Tout part d’une idée juste. Avant d’investir le moindre euro de production, "
     "ce pilier cherche le territoire où une demande réelle croise un potentiel "
     "business et une concurrence atteignable. C’est la décision la plus rentable "
     "de toute la méthode : se tromper de terrain coûte des mois.",
     [("Niche", "Choisir un territoire assez précis pour gagner, assez large pour passer à l’échelle."),
      ("Intention de recherche", "Comprendre ce que l’internaute veut vraiment derrière chaque requête."),
      ("Potentiel business", "Évaluer la capacité du sujet à générer du chiffre d’affaires, pas seulement du trafic."),
      ("Concurrence SERP", "Lire les pages déjà classées pour jauger la difficulté réelle, page par page."),
      ("Opportunité cachée", "Repérer les angles que les concurrents ont négligés ou mal traités.")]),

    ("validation", 2, 1, "Validation",
     "Confirmer, chiffres en main, que le marché est réel et monétisable.",
     "Une bonne idée non validée reste un pari. Ce pilier confronte l’intuition "
     "aux chiffres : volume réel, valeur économique, difficulté et délai de "
     "monétisation. On ne lance la production que sur les terrains qui passent "
     "ce filtre.",
     [("Volume réel", "Mesurer la demande réelle, au-delà des estimations approximatives des outils."),
      ("Coût du lead", "Estimer ce que coûterait le même lead acquis en publicité payante."),
      ("Valeur du client", "Calculer ce que rapporte un client acquis sur sa durée de vie."),
      ("Difficulté SEO", "Quantifier l’effort réel nécessaire pour se positionner durablement."),
      ("Vitesse de monétisation", "Estimer le délai entre la publication et le premier revenu.")]),

    ("architecture", 3, 2, "Architecture",
     "Des silos clairs, des pages money soutenues par leurs satellites.",
     "L’architecture décide où circule l’autorité. Des silos thématiques nets, "
     "des pages de conversion clairement identifiées et un maillage interne "
     "cohérent permettent à chaque contenu de renforcer les autres plutôt que "
     "de se concurrencer.",
     [("Silos", "Regrouper les contenus par thème pour concentrer la pertinence sémantique."),
      ("Pages money", "Identifier les pages qui doivent convertir et les prioriser."),
      ("Pages satellites", "Créer les contenus qui nourrissent et soutiennent les pages money."),
      ("Maillage interne", "Distribuer l’autorité par des liens internes logiques et descendants."),
      ("Profondeur de clic", "Garder les pages importantes à peu de clics de l’accueil.")]),

    ("mots-cles", 4, 2, "Mots-clés",
     "Couvrir l’intention complète, des requêtes argent à la longue traîne.",
     "Un mot-clé n’est qu’une porte d’entrée vers une intention. Ce pilier "
     "cartographie l’ensemble du champ : des requêtes commerciales aux questions "
     "précises de la longue traîne, en privilégiant les zones où la concurrence "
     "est faible.",
     [("Money keywords", "Cibler les requêtes à forte intention commerciale."),
      ("Longue traîne", "Couvrir les requêtes précises et peu concurrentielles qui convertissent."),
      ("Questions clients", "Répondre aux questions réelles que se posent les prospects."),
      ("Requêtes sous-exploitées", "Trouver la demande que personne ne traite correctement."),
      ("SERP faibles", "Viser les pages de résultats où la concurrence est vulnérable.")]),

    ("contenu", 5, 3, "Contenu",
     "Des piliers, des guides et des formats pensés autant pour l’humain que pour les LLM.",
     "Le contenu est l’endroit où la stratégie devient visible. Ce pilier produit "
     "des contenus de référence, des formats adaptés à chaque intention, et une "
     "structure pensée pour être à la fois lue par l’humain et citée par les "
     "modèles de langage.",
     [("Pages piliers", "Construire des contenus de référence exhaustifs sur les sujets clés."),
      ("Guides", "Accompagner l’internaute étape par étape vers son objectif."),
      ("Comparatifs", "Aider à la décision en comparant honnêtement les options."),
      ("FAQ", "Répondre clairement aux questions fréquentes — et nourrir le GEO."),
      ("Contenu programmatique", "Générer des pages à grande échelle à partir de données structurées."),
      ("Contenu pensé pour les LLM", "Structurer le contenu pour être compris et cité par les IA.")]),

    ("technique", 6, 3, "Technique",
     "Un site que Google crawle vite, comprend bien et sert sans friction.",
     "La technique est invisible quand elle est bonne, fatale quand elle est "
     "mauvaise. Ce pilier garantit que les robots explorent efficacement, que "
     "les bonnes pages sont indexées, et que l’expérience est rapide et propre.",
     [("Crawl", "S’assurer que Google explore le site efficacement, sans gaspillage de budget."),
      ("Indexation", "Vérifier que les pages utiles entrent bien dans l’index."),
      ("Logs serveur", "Analyser le comportement réel des robots, pas seulement les estimations."),
      ("Canonical", "Éviter la dilution causée par le contenu dupliqué."),
      ("Performance", "Servir des pages rapides et stables (Core Web Vitals)."),
      ("Schema", "Baliser le contenu en données structurées exploitables.")]),

    ("indexation", 7, 3, "Indexation",
     "S’assurer que chaque page utile entre — et reste — dans l’index.",
     "Une page non indexée n’existe pas pour Google. Ce pilier pilote l’entrée "
     "et le maintien des pages dans l’index, des nouvelles publications aux pages "
     "profondes, jusqu’à l’indexation à grande échelle.",
     [("Sitemap", "Lister les URL à explorer en priorité."),
      ("Search Console", "Piloter l’indexation depuis la source officielle de Google."),
      ("Découverte Google", "Faciliter la découverte rapide des nouvelles pages."),
      ("Pages profondes", "Faire indexer les pages éloignées de l’accueil."),
      ("Indexation de masse", "Gérer l’indexation à grande échelle, sous contrôle qualité.")]),

    ("autorite", 8, 4, "Autorité",
     "Construire une crédibilité thématique réelle, liens et mentions à l’appui.",
     "L’autorité, c’est la confiance accumulée. Ce pilier la construit par des "
     "liens de qualité, des mentions de marque et une cohérence thématique forte "
     "— pas par des raccourcis qui finissent par coûter cher.",
     [("Backlinks", "Obtenir des liens entrants de qualité, pertinents et durables."),
      ("Trafic GSC", "Suivre le trafic organique réel comme indicateur d’autorité."),
      ("Pertinence thématique", "Renforcer la cohérence du domaine sur son sujet de prédilection."),
      ("Mentions de marque", "Développer les citations, qu’elles soient liées ou non."),
      ("Liens déjà visibles", "Exploiter et optimiser les liens existants non valorisés.")]),

    ("signaux", 9, 4, "Signaux",
     "Lire les signaux utilisateurs pour confirmer que le contenu tient ses promesses.",
     "Les moteurs observent les utilisateurs. Ce pilier surveille le taux de clic, "
     "le comportement post-clic et les retours qualitatifs pour vérifier qu’une "
     "page satisfait réellement l’intention — et la corriger sinon.",
     [("CTR SERP", "Améliorer le taux de clic depuis les résultats de recherche."),
      ("Trafic référent", "Diversifier et solidifier les sources de trafic."),
      ("Trafic social", "Amplifier la portée des contenus via les réseaux."),
      ("Comportement post-clic", "Vérifier que la page satisfait l’intention de recherche."),
      ("Retours utilisateurs", "Écouter les signaux qualitatifs pour ajuster le contenu.")]),

    ("discover", 10, 4, "Discover",
     "Capter les pics de trafic Google Discover avec les bons angles, au bon moment.",
     "Google Discover récompense l’à-propos et l’engagement. Ce pilier identifie "
     "les angles porteurs, soigne les titres et la fraîcheur, et transforme les "
     "vagues d’attention en pics de trafic exploitables.",
     [("Angles chauds", "Identifier les sujets porteurs au bon moment."),
      ("Titres qui attirent", "Rédiger des titres qui déclenchent le clic sans tromper."),
      ("Fraîcheur", "Publier au bon moment et maintenir l’actualité du contenu."),
      ("Signaux externes", "S’appuyer sur la popularité et l’intérêt hors-site."),
      ("Pics de trafic", "Capter et exploiter les vagues de trafic Discover.")]),

    ("geo", 11, 4, "GEO",
     "Exister dans les réponses de ChatGPT, Perplexity et Google AI — entités et citations.",
     "Une part croissante des recherches se termine sans clic, dans une réponse "
     "générée par IA. Le GEO (Generative Engine Optimization) travaille les "
     "entités, la marque et les citations pour que vous soyez présent dans ces "
     "réponses.",
     [("Entités", "Être reconnu comme une entité claire par les moteurs et les IA."),
      ("Marque", "Renforcer la notoriété de marque, socle de la présence en GEO."),
      ("Citations", "Multiplier les citations dans des sources fiables et reconnues."),
      ("Contenu utile", "Produire le contenu factuel et structuré que les IA aiment citer."),
      ("Présence dans les réponses IA", "Apparaître dans ChatGPT, Perplexity et les AI Overviews.")]),

    ("automatisation", 12, 5, "Automatisation",
     "Des agents IA pour auditer, surveiller et détecter les opportunités à grande échelle.",
     "Ce qui est répétitif doit être automatisé. Ce pilier déploie des agents IA "
     "et des workflows pour auditer en masse, surveiller en continu et détecter "
     "les opportunités plus vite qu’un humain ne le pourrait.",
     [("Agents IA", "Déléguer les tâches répétitives à des agents fiables."),
      ("Audits massifs", "Auditer des milliers de pages en continu."),
      ("Monitoring", "Surveiller positions, indexation et incidents en temps réel."),
      ("Génération de pages", "Produire des pages à l’échelle, sous contrôle qualité strict."),
      ("Détection d’opportunités", "Repérer automatiquement les gains rapides à activer.")]),

    ("mesure", 13, 5, "Mesure",
     "Suivre la chaîne complète, de l’impression au revenu par page.",
     "On ne pilote que ce que l’on mesure. Ce pilier relie chaque étape — "
     "impressions, clics, positions, leads — jusqu’au revenu généré par chaque "
     "page, pour décider sur des faits et non des impressions.",
     [("Impressions", "Mesurer la visibilité réelle dans les résultats."),
      ("Clics", "Suivre le trafic effectivement capté."),
      ("Positions", "Suivre l’évolution des classements dans le temps."),
      ("Leads", "Relier le SEO aux demandes entrantes concrètes."),
      ("Revenu par page", "Attribuer un revenu à chaque page pour arbitrer.")]),

    ("optimisation", 14, 5, "Optimisation",
     "Renforcer, fusionner, élaguer et tester — sans jamais laisser un contenu stagner.",
     "Le SEO n’est jamais terminé. Ce pilier fait tourner la boucle "
     "d’amélioration : renforcer ce qui est proche du seuil, fusionner les "
     "redondances, supprimer ce qui dilue, et valider chaque hypothèse par le "
     "test.",
     [("Contenus à renforcer", "Améliorer les pages proches du seuil de performance."),
      ("Pages à fusionner", "Regrouper les contenus redondants pour concentrer la force."),
      ("Pages à supprimer", "Élaguer ce qui dilue la qualité globale du site."),
      ("Tests SEO", "Valider les hypothèses par l’expérimentation contrôlée."),
      ("Boucles d’amélioration", "Itérer en continu sur la base des données.")]),

    ("croissance", 15, 5, "Croissance",
     "Démultiplier ce qui marche : nouveaux silos, nouveaux médias, partenariats.",
     "Une fois la machine rodée, on la démultiplie. Ce pilier étend le périmètre "
     "— nouveaux silos, nouveaux sites, nouveaux médias et partenariats — pour "
     "transformer une réussite ponctuelle en croissance composée.",
     [("Nouveaux silos", "Étendre le périmètre thématique sur des bases saines."),
      ("Nouveaux sites", "Démultiplier le modèle sur de nouveaux domaines."),
      ("Nouveaux médias", "Investir d’autres canaux : vidéo, podcast, newsletter."),
      ("Partenariats", "Nouer des alliances éditoriales mutuellement profitables."),
      ("Actifs qui composent", "Construire des actifs dont la valeur croît d’elle-même.")]),

    ("objectif", 16, 5, "Objectif",
     "La finalité de tout l’édifice : une machine SEO qui transforme le trafic en ventes.",
     "Tous les piliers convergent ici. L’objectif n’est pas le trafic pour le "
     "trafic, mais un système complet qui attire les bons visiteurs, les "
     "transforme en leads puis en ventes, et installe une autorité durable : "
     "une véritable machine SEO.",
     [("Trafic qualifié", "Attirer les bons visiteurs, pas seulement du volume."),
      ("Leads entrants", "Transformer le trafic en demandes concrètes."),
      ("Ventes", "Convertir les leads en chiffre d’affaires réel."),
      ("Autorité", "Devenir une référence reconnue sur son marché."),
      ("Machine SEO", "Disposer d’un système qui tourne et compose dans le temps.")]),
]

# ── 3 services ───────────────────────────────────────────────────────────
# slug, titre, baseline, lede, intro, points[(titre, texte)]
SERVICES = [
    ("analytics", "Analytics",
     "Des chiffres auxquels vous pouvez enfin vous fier.",
     "Une architecture de mesure propre, des événements taggés correctement et "
     "des tableaux de bord lisibles. Vous arrêtez de douter de vos données et "
     "vous décidez sur du solide.",
     "La donnée ne vaut que si on lui fait confiance. Nous reconstruisons votre "
     "mesure de bout en bout — du plan de taggage au reporting — pour que chaque "
     "décision repose sur des chiffres justes.",
     [("Audit GA4 & plan de taggage",
       "Nous auditons votre installation Google Analytics 4, corrigeons le suivi "
       "et documentons un plan de taggage clair, aligné sur vos objectifs business."),
      ("Dashboards Looker Studio sur-mesure",
       "Des tableaux de bord lisibles qui répondent à vos vraies questions, mis à "
       "jour automatiquement, sans usine à gaz."),
      ("Tracking server-side & consentement",
       "Un suivi robuste et conforme : tracking server-side, gestion du "
       "consentement (RGPD) et fiabilisation des données malgré les blocages.")]),

    ("google-ads", "Google Ads",
     "L’acquisition payante pilotée par la donnée.",
     "Search, Performance Max, YouTube : des campagnes optimisées en continu, "
     "pas de budget en « set & forget ». Chaque euro investi est suivi et "
     "arbitré.",
     "La publicité payante complète le SEO : elle achète de la visibilité "
     "immédiate là où l’organique met du temps. Nous structurons, pilotons et "
     "optimisons vos campagnes pour un coût d’acquisition maîtrisé.",
     [("Stratégie d’enchères & structure de compte",
       "Une architecture de compte claire et une stratégie d’enchères adaptée à "
       "vos marges et à votre cycle de vente."),
      ("Création publicitaire orientée conversion",
       "Des annonces et des visuels conçus pour convertir, testés en continu "
       "pour faire émerger les meilleurs messages."),
      ("Reporting hebdomadaire et arbitrages",
       "Un suivi transparent chaque semaine, des arbitrages documentés et des "
       "décisions prises avec vous, pas à votre place.")]),

    ("intelligence-artificielle", "Intelligence Artificielle",
     "Conseil, formation et déploiement — pour vous rendre autonomes.",
     "De l’automatisation simple à l’agent métier sur-mesure. Nous déployons "
     "l’IA là où elle crée de la valeur, et nous formons vos équipes pour "
     "qu’elles s’en emparent.",
     "L’IA n’a de valeur que si elle sert un usage concret. Nous partons de vos "
     "processus réels pour identifier les automatisations utiles, les déployer "
     "et transmettre les compétences à vos équipes.",
     [("Audit des usages IA dans votre organisation",
       "Nous cartographions les tâches où l’IA fait gagner du temps et de la "
       "qualité, et priorisons les chantiers à fort impact."),
      ("Workflows d’automatisation (Make, n8n)",
       "Des automatisations fiables qui relient vos outils, suppriment les "
       "tâches répétitives et libèrent du temps à vos équipes."),
      ("Programmes de formation sur-mesure",
       "Des formations concrètes et adaptées à vos métiers, pour que vos équipes "
       "deviennent autonomes au lieu de rester dépendantes.")]),
]

# ── Fragments communs ────────────────────────────────────────────────────
FONTS = (
    '<link rel="preconnect" href="https://fonts.googleapis.com" />\n'
    '  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />\n'
    '  <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT@9..144,300..800,0..100&family=Inter+Tight:wght@300;400;500;600&display=swap" rel="stylesheet" />'
)


def header(prefix, active):
    """active in {'services','methode','approche'}"""
    def cur(key):
        return ' aria-current="page"' if key == active else ''
    return f'''  <header class="site-header" role="banner">
    <div class="container header-inner">
      <a href="{prefix}index.html" class="brand" aria-label="SIBYX — accueil">
        <img src="{prefix}assets/logo.svg" alt="" class="brand-logo" width="44" height="44" />
        <span class="brand-text">
          <span class="brand-name">SIBYX</span>
          <span class="brand-sub">Intelligence Digitale</span>
        </span>
      </a>

      <nav class="nav-primary" aria-label="Navigation principale">
        <ul>
          <li><a href="{prefix}index.html#services"{cur('services')}>Services</a></li>
          <li><a href="{prefix}methode-seo.html"{cur('methode')}>Méthode SEO</a></li>
          <li><a href="{prefix}index.html#approche"{cur('approche')}>Approche</a></li>
          <li><a href="{prefix}index.html#contact" class="nav-cta">Nous parler</a></li>
        </ul>
      </nav>

      <button class="nav-toggle" aria-expanded="false" aria-controls="mobile-nav" aria-label="Ouvrir le menu">
        <span></span><span></span><span></span>
      </button>
    </div>

    <nav id="mobile-nav" class="nav-mobile" aria-label="Navigation mobile" hidden>
      <ul>
        <li><a href="{prefix}index.html#services">Services</a></li>
        <li><a href="{prefix}methode-seo.html">Méthode SEO</a></li>
        <li><a href="{prefix}index.html#approche">Approche</a></li>
        <li><a href="{prefix}index.html#contact">Nous parler</a></li>
      </ul>
    </nav>
  </header>'''


def footer(prefix):
    return f'''  <footer class="site-footer" role="contentinfo">
    <div class="container footer-inner">
      <div class="footer-brand">
        <img src="{prefix}assets/logo.svg" alt="" class="footer-logo" width="48" height="48" />
        <div>
          <p class="footer-name">SIBYX</p>
          <p class="footer-sub">Intelligence Digitale</p>
        </div>
      </div>

      <div class="footer-cols">
        <div>
          <h4>Services</h4>
          <ul>
            <li><a href="{prefix}analytics.html">Analytics</a></li>
            <li><a href="{prefix}google-ads.html">Google Ads</a></li>
            <li><a href="{prefix}methode-seo.html">SEO &amp; GEO</a></li>
            <li><a href="{prefix}intelligence-artificielle.html">Intelligence Artificielle</a></li>
          </ul>
        </div>
        <div>
          <h4>Navigation</h4>
          <ul>
            <li><a href="{prefix}methode-seo.html">Méthode SEO</a></li>
            <li><a href="{prefix}index.html#approche">Approche</a></li>
            <li><a href="{prefix}index.html#contact">Contact</a></li>
            <li><a href="{prefix}mentions-legales.html">Mentions légales</a></li>
          </ul>
        </div>
        <div>
          <h4>Contact</h4>
          <ul>
            <li><a href="mailto:mistercamara27@gmail.com">mistercamara27@gmail.com</a></li>
            <li><a href="https://wa.me/22383728139" target="_blank" rel="noopener">WhatsApp Bamako</a></li>
            <li>Paris · Bamako</li>
          </ul>
        </div>
      </div>
    </div>

    <div class="container footer-bottom">
      <p>&copy; <span id="year">2026</span> SIBYX — Intelligence Digitale. Tous droits réservés.</p>
      <p class="footer-tagline">
        <em>Siby</em>, lieu d’origine au cœur du Mandé.
      </p>
    </div>
  </footer>'''


# ── Génération des pages piliers ─────────────────────────────────────────
def render_pillar(i):
    slug, num, phase, title, lede, intro, items = PILLARS[i]
    prefix = "../"
    url = f"{BASE}/methode/{slug}.html"
    nn = f"{num:02d}"
    phase_name = PHASES[phase]

    prev_html = ""
    if i > 0:
        p = PILLARS[i - 1]
        prev_html = f'<a class="silo-prev" href="{p[0]}.html"><span>← Pilier {p[1]:02d}</span>{p[3]}</a>'
    else:
        prev_html = '<span></span>'
    next_html = ""
    if i < len(PILLARS) - 1:
        n = PILLARS[i + 1]
        next_html = f'<a class="silo-next" href="{n[0]}.html"><span>Pilier {n[1]:02d} →</span>{n[3]}</a>'
    else:
        next_html = '<span></span>'

    items_html = "\n".join(
        f'''          <div class="def-item">
            <h3 class="def-term">{nm}</h3>
            <p class="def-desc">{ex}</p>
          </div>''' for nm, ex in items)

    return f'''<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="theme-color" content="#0E2240" />

  <title>Pilier {nn} · {title} — Méthode SEO SIBYX</title>
  <meta name="description" content="{title} — pilier {nn} de la méthode SEO SIBYX ({phase_name}). {lede}" />
  <meta name="author" content="SIBYX — Intelligence Digitale" />

  <meta property="og:type" content="article" />
  <meta property="og:title" content="Pilier {nn} · {title} — Méthode SEO SIBYX" />
  <meta property="og:description" content="{lede}" />
  <meta property="og:locale" content="fr_FR" />
  <meta property="og:site_name" content="SIBYX" />
  <meta property="og:url" content="{url}" />
  <meta property="og:image" content="{BASE}/assets/og-cover.svg" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="Pilier {nn} · {title} — Méthode SEO SIBYX" />
  <meta name="twitter:description" content="{lede}" />
  <meta name="twitter:image" content="{BASE}/assets/og-cover.svg" />

  <link rel="canonical" href="{url}" />
  <link rel="icon" type="image/svg+xml" href="{prefix}assets/favicon.svg" />
  {FONTS}

  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "Pilier {nn} · {title} — Méthode SEO SIBYX",
    "description": "{lede}",
    "inLanguage": "fr-FR",
    "url": "{url}",
    "isPartOf": {{"@type": "Article", "name": "Méthode SEO SIBYX", "url": "{BASE}/methode-seo.html"}},
    "author": {{"@type": "Organization", "name": "SIBYX — Intelligence Digitale"}},
    "publisher": {{"@type": "Organization", "name": "SIBYX — Intelligence Digitale", "url": "{BASE}/"}}
  }}
  </script>
  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [
      {{"@type": "ListItem", "position": 1, "name": "Accueil", "item": "{BASE}/"}},
      {{"@type": "ListItem", "position": 2, "name": "Méthode SEO", "item": "{BASE}/methode-seo.html"}},
      {{"@type": "ListItem", "position": 3, "name": "{title}", "item": "{url}"}}
    ]
  }}
  </script>

  <link rel="stylesheet" href="{prefix}styles.css" />
</head>

<body>
  <a class="skip-link" href="#main">Aller au contenu</a>

{header(prefix, 'methode')}

  <main id="main">
    <section class="hero method-hero" aria-labelledby="hero-title">
      <div class="container hero-inner">
        <nav class="breadcrumb" aria-label="Fil d'Ariane">
          <a href="{prefix}index.html">Accueil</a>
          <span aria-hidden="true">/</span>
          <a href="{prefix}methode-seo.html">Méthode SEO</a>
          <span aria-hidden="true">/</span>
          <span aria-current="page">{title}</span>
        </nav>

        <p class="hero-kicker">
          <span class="kicker-dot" aria-hidden="true"></span>
          Pilier {nn} · {phase_name}
        </p>

        <h1 id="hero-title" class="hero-title">{title}</h1>

        <p class="hero-lede">{lede}</p>

        <div class="hero-actions">
          <a href="{prefix}index.html#contact" class="btn btn-primary">
            Auditer ce pilier
            <span class="btn-arrow" aria-hidden="true">→</span>
          </a>
          <a href="{prefix}methode-seo.html" class="btn btn-ghost">Voir les 16 piliers</a>
        </div>
      </div>
    </section>

    <section class="pillar-detail" aria-labelledby="detail-title">
      <div class="container pillar-detail-inner">
        <header class="section-head">
          <p class="section-kicker">Ce que couvre ce pilier</p>
          <h2 id="detail-title" class="section-title">{title}, <em>en pratique</em>.</h2>
          <p class="section-lede">{intro}</p>
        </header>

        <div class="def-grid">
{items_html}
        </div>

        <nav class="silo-nav" aria-label="Piliers précédent et suivant">
          {prev_html}
          {next_html}
        </nav>
      </div>
    </section>

    <section class="cta-band" aria-labelledby="cta-title">
      <div class="container cta-inner">
        <h2 id="cta-title" class="cta-title">Faisons le point sur <em>votre {title.lower()}</em>.</h2>
        <p class="cta-lede">
          Un audit SIBYX situe votre site sur ce pilier et le relie aux 15 autres.
          30 minutes d’échange suffisent pour démarrer.
        </p>
        <a href="{prefix}index.html#contact" class="btn btn-primary btn-large">
          Demander un audit
          <span class="btn-arrow" aria-hidden="true">→</span>
        </a>
      </div>
    </section>
  </main>

{footer(prefix)}

  <script src="{prefix}script.js" defer></script>
</body>
</html>
'''


def render_service(s):
    slug, title, baseline, lede, intro, points = s
    prefix = ""
    url = f"{BASE}/{slug}.html"
    points_html = "\n".join(
        f'''          <li class="service-card">
            <span class="service-num">{i+1:02d}</span>
            <h3 class="service-title">{pt}</h3>
            <p class="service-desc">{tx}</p>
          </li>''' for i, (pt, tx) in enumerate(points))

    return f'''<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="theme-color" content="#0E2240" />

  <title>{title} — SIBYX · {baseline}</title>
  <meta name="description" content="{title} chez SIBYX : {lede}" />
  <meta name="author" content="SIBYX — Intelligence Digitale" />

  <meta property="og:type" content="website" />
  <meta property="og:title" content="{title} — SIBYX" />
  <meta property="og:description" content="{baseline}" />
  <meta property="og:locale" content="fr_FR" />
  <meta property="og:site_name" content="SIBYX" />
  <meta property="og:url" content="{url}" />
  <meta property="og:image" content="{BASE}/assets/og-cover.svg" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="{title} — SIBYX" />
  <meta name="twitter:description" content="{baseline}" />
  <meta name="twitter:image" content="{BASE}/assets/og-cover.svg" />

  <link rel="canonical" href="{url}" />
  <link rel="icon" type="image/svg+xml" href="assets/favicon.svg" />
  {FONTS}

  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@type": "Service",
    "name": "{title}",
    "serviceType": "{title}",
    "description": "{lede}",
    "url": "{url}",
    "areaServed": ["FR", "ML", "Afrique de l'Ouest"],
    "provider": {{"@type": "Organization", "name": "SIBYX — Intelligence Digitale", "url": "{BASE}/"}}
  }}
  </script>
  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [
      {{"@type": "ListItem", "position": 1, "name": "Accueil", "item": "{BASE}/"}},
      {{"@type": "ListItem", "position": 2, "name": "{title}", "item": "{url}"}}
    ]
  }}
  </script>

  <link rel="stylesheet" href="styles.css" />
</head>

<body>
  <a class="skip-link" href="#main">Aller au contenu</a>

{header(prefix, 'services')}

  <main id="main">
    <section class="hero method-hero" aria-labelledby="hero-title">
      <div class="container hero-inner">
        <nav class="breadcrumb" aria-label="Fil d'Ariane">
          <a href="index.html">Accueil</a>
          <span aria-hidden="true">/</span>
          <a href="index.html#services">Services</a>
          <span aria-hidden="true">/</span>
          <span aria-current="page">{title}</span>
        </nav>

        <p class="hero-kicker">
          <span class="kicker-dot" aria-hidden="true"></span>
          Service SIBYX
        </p>

        <h1 id="hero-title" class="hero-title">{title}</h1>
        <p class="hero-lede">{lede}</p>

        <div class="hero-actions">
          <a href="index.html#contact" class="btn btn-primary">
            Démarrer un échange
            <span class="btn-arrow" aria-hidden="true">→</span>
          </a>
          <a href="index.html#services" class="btn btn-ghost">Tous nos services</a>
        </div>
      </div>
    </section>

    <section class="services" aria-labelledby="what-title">
      <div class="container">
        <header class="section-head">
          <p class="section-kicker">Ce que nous faisons</p>
          <h2 id="what-title" class="section-title">{title}, <em>concrètement</em>.</h2>
          <p class="section-lede">{intro}</p>
        </header>

        <ol class="service-grid" role="list">
{points_html}
        </ol>
      </div>
    </section>

    <section class="cta-band" aria-labelledby="cta-title">
      <div class="container cta-inner">
        <h2 id="cta-title" class="cta-title">Un besoin en <em>{title.lower()}</em>&nbsp;?</h2>
        <p class="cta-lede">
          30 minutes d’échange suffisent pour savoir si nous pouvons vous aider.
          Sans engagement, sans présentation commerciale.
        </p>
        <a href="index.html#contact" class="btn btn-primary btn-large">
          Prendre rendez-vous
          <span class="btn-arrow" aria-hidden="true">→</span>
        </a>
      </div>
    </section>
  </main>

{footer(prefix)}

  <script src="script.js" defer></script>
</body>
</html>
'''


def write(path, content):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as f:
        f.write(content)
    print("écrit:", path)


def render_sitemap():
    rows = []

    def add(loc, freq, prio):
        rows.append(
            f"  <url>\n    <loc>{loc}</loc>\n    <changefreq>{freq}</changefreq>\n    <priority>{prio}</priority>\n  </url>")

    add(f"{BASE}/", "monthly", "1.0")
    add(f"{BASE}/methode-seo.html", "monthly", "0.9")
    for slug, *_ in SERVICES:
        add(f"{BASE}/{slug}.html", "monthly", "0.8")
    for slug, *_ in PILLARS:
        add(f"{BASE}/methode/{slug}.html", "monthly", "0.6")
    add(f"{BASE}/mentions-legales.html", "yearly", "0.3")
    body = "\n".join(rows)
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
{body}
</urlset>
'''


def main():
    for i in range(len(PILLARS)):
        write(f"methode/{PILLARS[i][0]}.html", render_pillar(i))
    for s in SERVICES:
        write(f"{s[0]}.html", render_service(s))
    write("sitemap.xml", render_sitemap())
    print("OK —", len(PILLARS), "piliers,", len(SERVICES), "services, sitemap régénéré.")


if __name__ == "__main__":
    main()
