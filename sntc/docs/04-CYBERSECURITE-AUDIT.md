# 04 — Plan de cybersécurité & audit

Système gouvernemental critique manipulant des données sensibles (flux
énergétiques nationaux, infractions). La sécurité est traitée comme une
exigence de premier ordre.

## 1. Modèle de menaces (principales)

| Menace | Impact | Contre-mesure |
|---|---|---|
| Falsification d'une livraison (faux QR) | Détournement masqué | `qr_token` aléatoire signé + géofencing arrivée + photo horodatée |
| Saisie de fausses ventes pour masquer une rétention | Écart caché | Recoupement stock physique/théorique, inspections contrôleurs, audit |
| Accès à des données hors périmètre | Fuite | **RLS** stricte par rôle, vérifiée à chaque requête |
| Vol de terminal | Usurpation | Session JWT expirable (1 h) + rotation refresh token + déconnexion à distance |
| Compromission compte admin | Vision/contrôle national | MFA obligatoire, journal d'audit, principe du moindre privilège |
| Injection / abus API | Corruption | PostgREST paramétré, validation côté edge functions, `max_rows` |
| Exfiltration des photos | Fuite | Buckets privés + URLs signées en production |

## 2. Authentification & autorisation

- **Supabase Auth**, comptes provisionnés par l'admin (inscription publique
  désactivée — `enable_signup = false`).
- **Rôles dans le JWT** (`app_metadata.role`) : non modifiables par
  l'utilisateur, alimentent toutes les politiques RLS.
- **MFA obligatoire** pour `admin_national` et `controleur`.
- Mots de passe : politique de complexité, rotation, blocage après échecs.
- JWT court (1 h) + rotation des refresh tokens activée.
- **Moindre privilège** : gérant = sa station, chauffeur = ses livraisons.

## 3. Sécurité des données

- **RLS activée sur toutes les tables** (`0004_rls.sql`), y compris vues
  (`security_invoker`).
- Chiffrement **en transit** (HTTPS/TLS) et **au repos** (Postgres + Storage).
- Données personnelles minimisées (nom, téléphone) — base légale : mission de
  service public ; durée de conservation définie par arrêté.
- Buckets de photos **privés** en production, accès par URL signée à durée
  limitée.
- Secrets (`service_role`, `CRON_SECRET`, tokens) **hors du dépôt** :
  `.gitignore` couvre `config.js` et `.env`. Gestion via le coffre Supabase /
  un secret manager.

## 4. Journalisation & audit

- Table `sntc.audit_log` (acteur, action, cible, données, IP, horodatage),
  lisible **par l'admin uniquement**.
- Événements sensibles à journaliser : création/validation de livraison,
  résolution d'alerte, relevé d'infraction, modification de seuils, gestion de
  comptes.
- Conservation des journaux ≥ 12 mois ; intégrité (append-only, export signé).
- Revue d'audit trimestrielle par un tiers indépendant.

> **Renforcement recommandé** : ajouter des triggers `AFTER` sur les tables
> critiques pour alimenter `audit_log` automatiquement (squelette fourni, à
> compléter selon les exigences réglementaires).

## 5. Sécurité applicative

- Validation des entrées dans les edge functions (volumes, produits, présence
  photo, format QR).
- Vérification du **token QR** côté serveur (jamais de confiance au client).
- **Géofencing** de la validation d'arrivée (rayon 300 m) ; les validations
  hors zone sont signalées (`hors_zone`) pour revue.
- CORS restreint aux origines officielles en production.
- Idempotence des écritures hors-ligne (`client_uuid`) — pas de double comptage.

## 6. Disponibilité & résilience

- Sauvegardes PITR, test de restauration mensuel.
- Limitation de débit (rate limiting) sur l'API et les edge functions.
- Surveillance : alertes d'exploitation (latence, taux d'erreur, échecs auth).

## 7. Audit de conformité (cycle)

1. **Avant pilote** : test d'intrusion (pentest) externe, revue de code,
   revue des politiques RLS, rotation de tous les secrets de démo.
2. **Pendant le pilote** : revue mensuelle des journaux, suivi des incidents.
3. **Avant généralisation** : audit complet (technique + organisationnel),
   homologation de sécurité, plan de réponse à incident formalisé.

## 8. Checklist de mise en production

- [ ] Tous les mots de passe de démo changés ; comptes de démo supprimés.
- [ ] MFA activé pour admin et contrôleurs.
- [ ] Buckets Storage privés + URLs signées.
- [ ] `CRON_SECRET` et clés `service_role` en coffre, jamais commités.
- [ ] CORS restreint aux domaines officiels.
- [ ] Sauvegardes PITR activées + restauration testée.
- [ ] Rate limiting configuré.
- [ ] Journal d'audit alimenté et exporté périodiquement.
- [ ] Pentest réalisé et findings corrigés.
- [ ] DPIA / analyse d'impact sur la protection des données réalisée.
