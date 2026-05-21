# SIBYX — Site vitrine

Site vitrine officiel de **SIBYX — Intelligence Digitale**.
Statique, sans dépendance, optimisé pour GitHub Pages.

URL de production : `https://sybyx27.github.io/sibyx/`

## Structure

```
sibyx-site/
├── index.html              Page d'accueil
├── mentions-legales.html   Mentions légales / RGPD
├── styles.css              Styles (design tokens, responsive)
├── script.js               Interactions (nav mobile, formulaire)
├── robots.txt              Indexation moteurs
├── sitemap.xml             Plan de site
├── README.md               Ce fichier
└── assets/
    ├── logo.svg            Logo "Arc mandé" complet
    └── favicon.svg         Favicon simplifié
```

## Stack

- HTML5 sémantique
- CSS moderne (variables, clamp, grid, intersection observer)
- Vanilla JS (pas de framework, pas de bundler)
- Polices : **Fraunces** (display) + **Inter Tight** (corps) via Google Fonts
- Logo en SVG (parfait sur tout écran)

## Déploiement sur GitHub Pages

1. Sur GitHub, créez un nouveau repo nommé `sibyx`.
2. Uploadez tous les fichiers ci-dessus (interface web : "Add file → Upload files").
3. **Settings → Pages → Build and deployment**
   - Source : `Deploy from a branch`
   - Branch : `main`, dossier `/ (root)`
   - **Save**
4. Le site est en ligne sous 1 à 3 minutes à l'adresse :
   `https://sybyx27.github.io/sibyx/`

## Personnalisations rapides

| Élément | Fichier | Repère |
|---|---|---|
| Couleurs | `styles.css` | bloc `:root` (`--navy`, `--gold`, etc.) |
| Logo | `assets/logo.svg` | SVG modifiable |
| Email | `index.html`, `mentions-legales.html`, `script.js` | `mistercamara27@gmail.com` |
| WhatsApp | `index.html`, `mentions-legales.html` | `https://wa.me/22300000000` |
| Textes services | `index.html` | section `#services` |

## Branchement Formspree (formulaire qui envoie vraiment)

Par défaut, le formulaire utilise un fallback `mailto:` (ouvre le client mail).
Pour recevoir directement les demandes dans Gmail sans rien installer :

1. Créez un compte gratuit sur [formspree.io](https://formspree.io) (50 envois/mois gratuits).
2. Créez un nouveau formulaire avec destination `mistercamara27@gmail.com`.
3. Copiez votre ID de formulaire (du type `xyzabc123`).
4. Dans `index.html`, remplacez :
   ```html
   action="https://formspree.io/f/VOTRE_ID_FORMSPREE"
   ```
   par :
   ```html
   action="https://formspree.io/f/xyzabc123"
   ```
5. Commitez. C'est tout.

## Google Analytics 4

Pour suivre les visites :

1. Créez une propriété GA4 sur [analytics.google.com](https://analytics.google.com).
2. Copiez votre Measurement ID (du type `G-XXXXXXXXXX`).
3. Ajoutez ce snippet dans `<head>` de **index.html** ET de **mentions-legales.html**, juste avant `</head>` :
   ```html
   <script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
   <script>
     window.dataLayer = window.dataLayer || [];
     function gtag(){dataLayer.push(arguments);}
     gtag('js', new Date());
     gtag('config', 'G-XXXXXXXXXX', { anonymize_ip: true });
   </script>
   ```

## Google Search Console

1. Allez sur [search.google.com/search-console](https://search.google.com/search-console).
2. Ajoutez la propriété URL : `https://sybyx27.github.io/sibyx/`
3. Méthode de vérification : balise HTML.
4. Copiez la balise `<meta name="google-site-verification" content="...">` et collez-la dans le `<head>` de `index.html`.
5. Une fois vérifié, soumettez votre sitemap : `https://sybyx27.github.io/sibyx/sitemap.xml`

## Accessibilité

- WCAG 2.1 AA visé (contrastes vérifiés)
- Navigation clavier complète + focus visible
- Skip link en début de page
- `prefers-reduced-motion` respecté

## Licence

Code propriétaire SIBYX. Tous droits réservés.

---

*« Siby », lieu d'origine au cœur du Mandé.*
