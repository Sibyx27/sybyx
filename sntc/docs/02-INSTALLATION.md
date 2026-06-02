# 02 — Installation

## Prérequis

- [Supabase CLI](https://supabase.com/docs/guides/cli) ≥ 1.180
- Docker (pour Supabase en local) **ou** un projet Supabase hébergé
- Node.js ≥ 18 et npm (application mobile)
- [Deno](https://deno.com/) (scripts de provisionnement)
- Un compte [Mapbox](https://account.mapbox.com/) (token public `pk....`)

---

## 1. Base de données & backend

### Option A — Local (développement)

```bash
cd sntc/supabase
supabase start              # démarre Postgres + Studio + Auth en local
supabase db reset           # applique les migrations 0001→0006

# Les données de démo dépendent des comptes auth -> on crée les comptes AVANT
export SUPABASE_URL="http://localhost:54321"
export SUPABASE_SERVICE_ROLE_KEY="<service_role affichée par supabase start>"
deno run --allow-env --allow-net ../scripts/seed_users.ts

# Puis on charge les données métier de démonstration
psql "postgresql://postgres:postgres@localhost:54322/postgres" -f seed/demo_bamako.sql
```

`supabase start` affiche `API URL`, `anon key` et `service_role key`. Notez-les.

> ⚠ **Ordre obligatoire** : migrations → `seed_users.ts` → `demo_bamako.sql`.
> Les profils référencent `auth.users` ; les comptes doivent exister d'abord
> (l'étape 2 ci-dessous peut donc être exécutée avant le seed métier).

### Option B — Projet hébergé (pilote)

```bash
cd sntc/supabase
supabase link --project-ref <REF_PROJET>
supabase db push                                   # applique les migrations
psql "$DATABASE_URL" -f seed/demo_bamako.sql        # charge les données de démo
supabase functions deploy creer-livraison valider-arrivee balayage-alertes
```

Configurez les secrets des edge functions :

```bash
supabase secrets set CRON_SECRET="$(openssl rand -hex 24)"
```

Créez les buckets de stockage (photos) dans Studio → Storage :
- `livraisons` (public en lecture pour le pilote, privé recommandé en prod)
- `inspections`

> ⚠ `pg_cron` (migration 0006) doit être activé dans Studio → Database →
> Extensions. À défaut, planifiez l'edge function `balayage-alertes` via un cron
> externe (en-tête `x-cron-secret`).

---

## 2. Comptes de démonstration

```bash
export SUPABASE_URL="https://<REF>.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="<service_role_key>"
deno run --allow-env --allow-net sntc/scripts/seed_users.ts
```

Crée admin, contrôleur, 2 gérants et 1 chauffeur (mot de passe `Sntc!Demo2026`).

---

## 3. Tableau de bord web

```bash
cd sntc/web-dashboard
cp config.example.js config.js
# éditez config.js : SUPABASE_URL, SUPABASE_ANON_KEY, MAPBOX_TOKEN
python3 -m http.server 8080
```

Ouvrez http://localhost:8080 et connectez-vous en `admin@sntc.ml`.

Déploiement statique : n'importe quel hébergeur (Netlify, Vercel, Nginx,
GitHub Pages). `config.js` n'est **pas** versionné — déployez-le séparément.

---

## 4. Application mobile

```bash
cd sntc/mobile
npm install
```

Renseignez les clés dans `app.json` → `expo.extra` :

```json
"extra": {
  "supabaseUrl": "https://<REF>.supabase.co",
  "supabaseAnonKey": "<anon_key>",
  "mapboxToken": "<token>"
}
```

Lancement :

```bash
npm start            # QR Expo Go (dev)
npm run android      # émulateur / appareil branché
```

Build APK de pilote (Android prioritaire) :

```bash
npm i -g eas-cli && eas login
npm run build:android   # profil "preview" -> APK installable
```

---

## Vérification de l'installation

1. Connexion `admin@sntc.ml` sur le web → la carte montre 6 stations de Bamako
   colorées (vert/jaune/rouge/noir).
2. Connexion `gerant.aci@sntc.ml` sur mobile → saisir une vente → le stock
   diminue, l'écart se recalcule.
3. Connexion `chauffeur@sntc.ml` → une livraison `en_route` est visible.
4. KPI « stations en rupture » = 1 (Magnambougou), « suspectes » ≥ 1.

## Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| Carte vide | Token Mapbox absent/invalide | Vérifier `config.js` / `app.json` |
| « Accès réservé » au login web | Rôle gérant/chauffeur | Utiliser un compte admin/contrôleur |
| Ventes non synchronisées | Hors-ligne | Reviendront automatiquement (outbox) |
| Edge function 403 | JWT manquant / CRON_SECRET | Vérifier en-têtes et secrets |
