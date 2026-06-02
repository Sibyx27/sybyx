# 05 — API REST

L'API est exposée par **PostgREST** (Supabase) sur le schéma `sntc`, complétée
par trois **edge functions** pour la logique non triviale. Toutes les routes
respectent le **RLS** : les données renvoyées dépendent du rôle porté par le JWT.

- Base URL : `https://<REF>.supabase.co`
- En-têtes communs :
  ```
  apikey: <ANON_KEY>
  Authorization: Bearer <ACCESS_TOKEN>
  Content-Type: application/json
  ```
- Schéma : `Accept-Profile: sntc` (GET) / `Content-Profile: sntc` (écritures),
  ou client configuré avec `db: { schema: "sntc" }`.

---

## Authentification

```http
POST /auth/v1/token?grant_type=password
{ "email": "gerant.aci@sntc.ml", "password": "..." }
→ { access_token, refresh_token, user }
```

---

## Tables REST (extrait)

### Stations
```http
GET /rest/v1/stations?select=*&etat=eq.rupture
GET /rest/v1/v_carte_stations?select=*            # vue carte (couleurs)
```

### Stocks
```http
GET /rest/v1/stocks?station_id=eq.<uuid>
# Relevé physique (gérant) — déclenche le recalcul théorique côté base :
POST /rest/v1/stocks
Prefer: resolution=merge-duplicates
{ "station_id":"<uuid>", "produit":"gasoil", "stock_physique": 12000 }
```

### Ventes (saisie, idempotente)
```http
POST /rest/v1/ventes
Prefer: resolution=merge-duplicates
{ "station_id":"<uuid>", "produit":"gasoil", "volume": 45.5,
  "client_uuid":"<uuid-genere-mobile>" }
```
> Le couple `(station_id, client_uuid)` est unique : rejouer la requête ne crée
> pas de doublon (synchro hors-ligne sûre).

### Historique des ventes / consommation
```http
GET /rest/v1/ventes?station_id=eq.<uuid>&order=vendue_le.desc
GET /rest/v1/v_consommation_journaliere?station_id=eq.<uuid>
```

### Alertes
```http
GET /rest/v1/alertes?resolue=eq.false&order=created_at.desc
PATCH /rest/v1/alertes?id=eq.<uuid>
{ "resolue": true, "resolue_le": "2026-06-02T10:00:00Z" }
```

### Inspections & infractions (contrôleur)
```http
POST /rest/v1/inspections    { station_id, controleur_id, releve_essence, releve_gasoil, rapport }
POST /rest/v1/infractions     { station_id, controleur_id, gravite, motif, description }
```

### Tableau de bord
```http
GET /rest/v1/v_dashboard_national   # KPIs nationaux (objet unique)
GET /rest/v1/v_stock_par_region
GET /rest/v1/v_stations_suspectes
```

---

## Edge Functions

### `POST /functions/v1/creer-livraison`
Crée un bon de livraison et renvoie la charge à encoder dans le QR Code.
```json
// Requête
{ "depot_id":"<uuid>", "station_id":"<uuid>", "produit":"gasoil",
  "volume_charge": 15000, "chauffeur_id":"<uuid>", "immatriculation":"BKO-4521-MD" }
// Réponse 201
{ "livraison": { "id":"...", "reference":"LIV-20260602-0003", "qr_token":"..." },
  "qr_payload": "{\"r\":\"LIV-20260602-0003\",\"t\":\"...\"}" }
```

### `POST /functions/v1/valider-arrivee`
Valide l'arrivée après scan du QR (token + géofencing + photo obligatoire).
```json
// Requête
{ "qr_token":"...", "volume_recu": 14980,
  "latitude": 12.6280, "longitude": -8.0490,
  "photo_url":"https://.../arrivees/....jpg" }
// Réponse 200
{ "livraison": {...}, "ecart": -20, "hors_zone": false, "message": "Arrivée validée" }
```
Codes : `400` champ manquant/photo absente · `404` QR invalide · `409` déjà
validée/annulée.

### `POST /functions/v1/balayage-alertes`
Tâche machine (en-tête `x-cron-secret`). Détecte livraisons non validées et
réévalue toutes les stations. Normalement déclenchée par `pg_cron` (15 min).

---

## Realtime

Le tableau de bord s'abonne aux changements pour un rafraîchissement live :
```js
supabase.channel('sntc-dashboard')
  .on('postgres_changes', { event:'*', schema:'sntc', table:'alertes' }, refresh)
  .on('postgres_changes', { event:'*', schema:'sntc', table:'stations' }, refresh)
  .subscribe();
```

---

## Codes d'erreur

| Code | Signification |
|---|---|
| 401 | JWT absent/expiré |
| 403 | Refusé par RLS (hors périmètre du rôle) |
| 409 | Conflit (ex. livraison déjà validée, doublon) |
| 422 | Données invalides |
