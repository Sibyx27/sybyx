# 03 — Plan de déploiement national

## Philosophie : du pilote Bamako à la couverture nationale

Déploiement **progressif et mesuré**, chaque phase validant la précédente avant
extension. L'objectif est de bâtir la confiance des acteurs (gérants,
distributeurs, syndicats de transporteurs) et de prouver la valeur avant la
généralisation.

---

## Phase 0 — Préparation (semaines 1-3)

- Cadre juridique : arrêté ministériel rendant la déclaration via SNTC
  obligatoire pour les stations du périmètre pilote ; protection des données.
- Gouvernance : désignation d'un comité de pilotage (Ministère de l'Énergie,
  ONAP/autorité de régulation, douanes, distributeurs).
- Référentiel : import du registre officiel des stations et dépôts (coordonnées
  GPS, capacités de cuves, enseignes).
- Sécurité : revue du [plan de cybersécurité](04-CYBERSECURITE-AUDIT.md),
  rotation des secrets, MFA pour les comptes admin/contrôleur.

## Phase 1 — Pilote Bamako (semaines 4-12)

- **Périmètre** : ~30 à 50 stations du district de Bamako + 2 dépôts.
- Déploiement Supabase hébergé (région la plus proche, sauvegardes activées).
- Distribution de l'APK aux gérants et chauffeurs ; formation terrain (2 h).
- Équipement : smartphones Android d'entrée de gamme suffisants.
- KPI de succès :
  - ≥ 90 % des livraisons tracées de bout en bout (QR + photo + GPS) ;
  - ≥ 80 % des ventes saisies quotidiennement ;
  - délai médian de détection d'une rupture < 1 h ;
  - ≥ 1 cas de rétention/écart détecté et traité.

## Phase 2 — Extension régionale (mois 4-9)

- Ajout des régions à fort trafic : Koulikoro, Sikasso, Ségou.
- Montée en charge technique (voir « Passage à l'échelle » ci-dessous).
- Recrutement et formation des contrôleurs régionaux.
- Tableau de bord régionalisé (vue `v_stock_par_region` déjà disponible).

## Phase 3 — Couverture nationale (mois 9-18)

- Toutes les régions, y compris zones à connectivité faible (mode hors-ligne
  critique ; envisager SMS/USSD de secours pour la saisie de vente).
- Interconnexion avec les systèmes douaniers et fiscaux (imports, taxes).
- Ouverture de données agrégées au public (transparence : stocks par région).

---

## Passage à l'échelle (technique)

| Levier | Action |
|---|---|
| Géo | Migrer `earthdistance` → **PostGIS** pour requêtes spatiales nationales |
| Ventes | **Partitionner** `sntc.ventes` par mois (volume élevé) |
| Lecture | Réplicas de lecture pour le tableau de bord national |
| Cartographie | Tuiles Mapbox + **clustering** des marqueurs au-delà de ~500 stations |
| Photos | Politique de rétention + archivage froid (coût stockage) |
| Temps réel | Limiter les canaux Realtime aux vues agrégées (éviter le fan-out) |
| Edge | Cache des KPIs nationaux (vue matérialisée rafraîchie par cron) |

## Connectivité faible / zones blanches

- Mode hors-ligne déjà natif (outbox idempotent).
- Compression agressive des photos (qualité 0.5, déjà en place).
- Option de repli **USSD/SMS** pour la déclaration de vente dans les zones sans
  data (passerelle opérateur → edge function).

## Formation & conduite du changement

- Fiches illustrées (1 page/rôle), vidéos courtes en bambara et en français.
- Hotline et référents régionaux.
- Tableau de bord d'adoption (taux de saisie par station) pour cibler
  l'accompagnement.

## Continuité d'activité

- Sauvegardes Point-in-Time activées (Supabase) ; test de restauration mensuel.
- Procédure dégradée papier (bon de livraison + QR imprimé) en cas de panne.
- RTO cible 4 h, RPO cible 15 min.

## Indicateurs nationaux suivis

Stock national (essence/gasoil), stock par région, livraisons du jour, stations
en rupture, stations suspectes, alertes critiques, délai moyen de détection,
taux de couverture (stations déclarantes / stations enregistrées).
