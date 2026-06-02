# 01 — Architecture

## Vue d'ensemble

```
┌──────────────────────┐        ┌──────────────────────┐
│  Mobile (Expo / RN)   │        │  Web (Mapbox + JS)    │
│  4 rôles · hors-ligne │        │  Tableau de bord gouv │
└──────────┬───────────┘        └──────────┬───────────┘
           │  HTTPS (REST + Realtime + Auth)            │
           └─────────────────┬──────────────────────────┘
                             ▼
                ┌────────────────────────────┐
                │          SUPABASE           │
                │  ┌──────────────────────┐   │
                │  │ Auth (JWT + rôles)    │   │
                │  ├──────────────────────┤   │
                │  │ PostgREST (API REST)  │   │
                │  ├──────────────────────┤   │
                │  │ Edge Functions (Deno) │   │  creer-livraison
                │  │                       │   │  valider-arrivee
                │  │                       │   │  balayage-alertes
                │  ├──────────────────────┤   │
                │  │ Storage (photos)      │   │
                │  ├──────────────────────┤   │
                │  │ PostgreSQL + RLS      │◄──┼── pg_cron (15 min)
                │  │  • triggers métier    │   │
                │  │  • calcul stock       │   │
                │  │  • alertes auto       │   │
                │  └──────────────────────┘   │
                └────────────────────────────┘
```

## Principes directeurs

1. **La logique métier vit dans la base.** Le calcul du stock théorique, la
   détection des écarts, la couleur des stations et la levée d'alertes sont
   implémentés en triggers/fonctions PostgreSQL (`0003_functions_triggers.sql`).
   Avantage décisif pour ce contexte : la cohérence est garantie même quand des
   clients hors-ligne synchronisent leurs données dans le désordre.

2. **Sécurité au niveau ligne (RLS) systématique.** Chaque table applique des
   politiques par rôle (`0004_rls.sql`). Un gérant ne voit jamais une autre
   station ; un chauffeur ne voit que ses livraisons. Le rôle est porté par le
   JWT (`app_metadata.role`) pour éviter une jointure à chaque requête.

3. **Hors-ligne d'abord.** Le mobile écrit dans une file locale (outbox) et
   rejoue les opérations à la reconnexion. L'idempotence est assurée par un
   `client_uuid` côté terminal + contrainte d'unicité côté base.

4. **API auto-générée.** PostgREST expose tables et vues en REST sans code
   serveur supplémentaire. Les edge functions ne portent que la logique qui ne
   peut pas être un simple INSERT/UPDATE (génération QR, vérification de token
   + géofencing, balayage planifié).

## Flux clés

### Livraison dépôt → station
1. Admin/gérant crée la livraison → edge function `creer-livraison` →
   trigger génère `reference` + `qr_token` → **QR Code émis**.
2. Chauffeur valide le départ → position GPS enregistrée → statut `en_route`.
3. Points GPS périodiques dans `livraison_positions` (suivi temps réel).
4. À la station, chauffeur **scanne le QR**, saisit le volume reçu, prend une
   **photo horodatée obligatoire** → edge function `valider-arrivee` vérifie le
   token + le **géofencing** (rayon 300 m) → statut `arrivee_validee`.
5. Le trigger recalcule le stock et lève une alerte si écart volume > 50 L.

### Calcul de stock & alertes
- Toute vente, toute livraison réceptionnée, tout relevé physique déclenche
  `recalculer_stock(station, produit)`.
- `evaluer_station()` recalcule la couleur (noir > rouge > jaune > vert) et lève
  ou résout les alertes (idempotent, pas de doublon d'alerte ouverte).
- `pg_cron` exécute `balayage_alertes()` toutes les 15 min pour détecter
  l'inactivité (sans-vente 24h) et les livraisons non validées (>12h).

## Modèle de données (résumé)

`regions · profiles · depots · stations · stocks · livraisons ·
livraison_positions · ventes · alertes · inspections · inspection_photos ·
infractions · audit_log`

Schéma complet : `supabase/migrations/0002_schema.sql`.
Vues du tableau de bord : `0005_views.sql`.

## Choix technologiques

| Besoin | Choix | Justification |
|---|---|---|
| Backend | Supabase | Postgres managé + Auth + REST + Realtime + Storage, time-to-pilot court |
| Géo (mobile/calc) | `earthdistance` | Suffisant pour distances dépôt↔station, plus léger que PostGIS |
| Carte (web) | Mapbox GL | Rendu vectoriel fluide, marqueurs colorés par état |
| Mobile | Expo | Build Android simple (EAS), accès caméra/GPS/stockage natif |
| Hors-ligne | AsyncStorage + outbox | Pas de dépendance lourde, idempotence par `client_uuid` |

> Pour un passage à l'échelle nationale, voir les recommandations de
> [03 — Déploiement national](03-DEPLOIEMENT-NATIONAL.md) (PostGIS, partitionnement
> des ventes, réplicas de lecture).
