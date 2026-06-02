# SNTC — Système National de Traçabilité des Carburants

Plateforme de suivi en temps réel des flux de carburant **du dépôt à la
station-service**, conçue pour aider l'État malien à lutter contre la rétention
volontaire, les ventes spéculatives, les pénuries artificielles, les
détournements de stock et les ventes hors circuit.

> **Statut** : socle complet prêt pour un **déploiement pilote sur Bamako**.

## Composants

| Dossier | Contenu | Stack |
|---|---|---|
| [`supabase/`](supabase/) | Base de données, RLS, logique métier, edge functions, seed | PostgreSQL · Supabase |
| [`mobile/`](mobile/) | Application terrain (4 rôles, hors-ligne) | React Native · Expo |
| [`web-dashboard/`](web-dashboard/) | Tableau de bord gouvernemental + carte nationale | HTML/JS · Mapbox |
| [`scripts/`](scripts/) | Provisionnement des comptes de démo | Deno |
| [`docs/`](docs/) | Architecture, installation, déploiement, cybersécurité, API | Markdown |

## Rôles

1. **Administrateur national** — vision pays entière, planification, comptes.
2. **Contrôleur** — inspections, photos, rapports, infractions (lecture nationale).
3. **Gérant de station** — stocks, ventes, réception des livraisons (sa station).
4. **Chauffeur-citerne** — validation départ/arrivée, GPS, scan QR.

## Modules

- **Livraisons** — QR unique, validation départ dépôt, suivi GPS, validation
  arrivée avec photo horodatée obligatoire, historique complet.
- **Stocks** — relevé physique essence/gasoil, **stock théorique calculé
  automatiquement** (`précédent + livraisons − ventes`), détection d'écarts.
- **Ventes** — saisie rapide, historique journalier, consommation calculée.
- **Alertes automatiques** — écart > seuil, station sans vente 24h, rupture
  imminente, rupture totale, livraison non validée.
- **Carte nationale** — toutes les stations, couleurs 🟢 normal / 🟡 faible /
  🔴 rupture / ⚫ inactive.
- **Inspection** — relevés, photos, rapports, infractions.
- **Tableau de bord** — stock national/régional, livraisons du jour, ruptures,
  stations suspectes, alertes critiques.

## Contraintes UX prises en compte

Interface volontairement minimale, **gros boutons**, saisie en un geste,
**fonctionnement hors-ligne** avec file d'attente et synchronisation idempotente
au retour du réseau, priorité **Android**.

## Démarrage rapide

```bash
# 1. Base de données + logique métier + données de démo
cd supabase && supabase start && supabase db reset

# 2. Comptes de démonstration
export SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=...
deno run --allow-env --allow-net ../scripts/seed_users.ts

# 3. Tableau de bord web
cp web-dashboard/config.example.js web-dashboard/config.js  # puis renseigner les clés
cd web-dashboard && python3 -m http.server 8080

# 4. Application mobile
cd mobile && npm install && npm start
```

Détails complets : **[docs/02-INSTALLATION.md](docs/02-INSTALLATION.md)**.

## Comptes de démonstration

| Rôle | Identifiant | Mot de passe |
|---|---|---|
| Administrateur | `admin@sntc.ml` | `Sntc!Demo2026` |
| Contrôleur | `controleur@sntc.ml` | `Sntc!Demo2026` |
| Gérant (ACI 2000) | `gerant.aci@sntc.ml` | `Sntc!Demo2026` |
| Chauffeur | `chauffeur@sntc.ml` | `Sntc!Demo2026` |

> ⚠ Mots de passe de démonstration. **À changer impérativement** avant tout
> usage réel (voir [plan de cybersécurité](docs/04-CYBERSECURITE-AUDIT.md)).

## Documentation

- [01 — Architecture](docs/01-ARCHITECTURE.md)
- [02 — Installation](docs/02-INSTALLATION.md)
- [03 — Déploiement national](docs/03-DEPLOIEMENT-NATIONAL.md)
- [04 — Cybersécurité & audit](docs/04-CYBERSECURITE-AUDIT.md)
- [05 — API REST](docs/05-API-REST.md)

## Licence

Logiciel d'État. Tous droits réservés — République du Mali.
