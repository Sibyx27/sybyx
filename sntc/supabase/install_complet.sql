-- =============================================================================
-- SNTC — INSTALLATION COMPLÈTE (fichier unique)
-- Regroupe les migrations 0001 à 0005. À coller en UNE fois dans le SQL Editor
-- de Supabase, puis cliquer « Run ». (La planification pg_cron 0006 est
-- volontairement exclue : optionnelle pour un test.)
-- =============================================================================


-- >>>>>>>>>>>>>>>>>>>>>>>>  migrations/0001_extensions.sql  <<<<<<<<<<<<<<<<<<<<<<<<

-- =============================================================================
-- SNTC — Système National de Traçabilité des Carburants
-- Migration 0001 — Extensions & schéma de base
-- =============================================================================
-- Active les extensions PostgreSQL nécessaires à la plateforme.
-- Exécuté en premier par `supabase db push`.
-- -----------------------------------------------------------------------------

-- Identifiants UUID (gen_random_uuid)
create extension if not exists "pgcrypto";

-- Recherche géospatiale légère (distance dépôt <-> station, géofencing arrivée)
-- earthdistance s'appuie sur cube ; suffisant et plus léger que PostGIS pour un pilote.
create extension if not exists "cube";
create extension if not exists "earthdistance";

-- Suppression des accents pour la recherche texte (noms de stations)
create extension if not exists "unaccent";

-- Schéma applicatif dédié (sépare le métier des objets Supabase internes)
create schema if not exists sntc;

comment on schema sntc is 'Objets métier du Système National de Traçabilité des Carburants';

-- >>>>>>>>>>>>>>>>>>>>>>>>  migrations/0002_schema.sql  <<<<<<<<<<<<<<<<<<<<<<<<

-- =============================================================================
-- SNTC — Migration 0002 — Schéma métier (tables, types, index)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TYPES ÉNUMÉRÉS
-- -----------------------------------------------------------------------------

-- Rôles applicatifs. Stockés aussi dans le JWT (app_metadata.role).
create type sntc.user_role as enum (
  'admin_national',   -- Administrateur national (accès total, lecture pays entier)
  'controleur',       -- Contrôleur / inspecteur de terrain
  'gerant',           -- Gérant de station-service
  'chauffeur'         -- Chauffeur-citerne
);

create type sntc.fuel_type as enum (
  'essence',
  'gasoil'
);

create type sntc.livraison_statut as enum (
  'creee',            -- Bon de livraison généré (QR émis)
  'depart_valide',    -- Départ dépôt confirmé (chauffeur)
  'en_route',         -- En cours d'acheminement (suivi GPS actif)
  'arrivee_validee',  -- Arrivée station confirmée + photo
  'ecart_signale',    -- Écart de volume constaté à la réception
  'annulee'
);

create type sntc.station_etat as enum (
  'normal',           -- Vert  — stock sain
  'faible',           -- Jaune — stock sous seuil d'alerte
  'rupture',          -- Rouge — stock épuisé (au moins un produit)
  'inactive'          -- Noir  — aucune activité / station fermée
);

create type sntc.alerte_type as enum (
  'ecart_stock',          -- Écart théorique/physique > seuil
  'sans_vente_24h',       -- Aucune vente enregistrée depuis 24h
  'rupture_imminente',    -- Autonomie estimée < seuil d'heures
  'rupture_totale',       -- Stock à zéro
  'livraison_non_validee' -- Livraison partie mais jamais réceptionnée
);

create type sntc.alerte_severite as enum ('info', 'attention', 'critique');

create type sntc.infraction_gravite as enum ('mineure', 'majeure', 'grave');

-- -----------------------------------------------------------------------------
-- RÉFÉRENTIEL TERRITORIAL
-- -----------------------------------------------------------------------------

create table sntc.regions (
  id          smallint primary key,
  nom         text not null unique,
  chef_lieu   text
);

comment on table sntc.regions is 'Régions administratives du Mali (référentiel)';

-- -----------------------------------------------------------------------------
-- PROFILS UTILISATEURS  (1:1 avec auth.users)
-- -----------------------------------------------------------------------------

create table sntc.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  role          sntc.user_role not null default 'gerant',
  nom_complet   text not null,
  telephone     text,
  region_id     smallint references sntc.regions(id),
  -- Pour un gérant/chauffeur : station de rattachement (NULL pour admin/contrôleur)
  station_id    uuid,            -- FK ajoutée après création de la table stations
  actif         boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

comment on table sntc.profiles is 'Profil applicatif lié à un compte auth.users';
comment on column sntc.profiles.station_id is 'Station de rattachement (gérant / chauffeur uniquement)';

-- -----------------------------------------------------------------------------
-- DÉPÔTS PÉTROLIERS
-- -----------------------------------------------------------------------------

create table sntc.depots (
  id          uuid primary key default gen_random_uuid(),
  nom         text not null,
  region_id   smallint references sntc.regions(id),
  adresse     text,
  latitude    double precision not null,
  longitude   double precision not null,
  actif       boolean not null default true,
  created_at  timestamptz not null default now()
);

comment on table sntc.depots is 'Dépôts pétroliers (points de départ des livraisons)';

-- -----------------------------------------------------------------------------
-- STATIONS-SERVICE
-- -----------------------------------------------------------------------------

create table sntc.stations (
  id              uuid primary key default gen_random_uuid(),
  code            text not null unique,          -- code court ex. "BKO-ACI-001"
  nom             text not null,
  enseigne        text,                          -- marque (Total, Oryx, Shell...)
  region_id       smallint references sntc.regions(id),
  commune         text,
  adresse         text,
  latitude        double precision not null,
  longitude       double precision not null,
  -- Capacités des cuves (litres)
  capacite_essence numeric(12,2) not null default 0,
  capacite_gasoil  numeric(12,2) not null default 0,
  -- Seuils de déclenchement d'alerte (litres) — paramétrables par station
  seuil_faible_essence numeric(12,2) not null default 2000,
  seuil_faible_gasoil  numeric(12,2) not null default 3000,
  -- Tolérance d'écart accepté avant alerte (litres)
  seuil_ecart     numeric(12,2) not null default 200,
  etat            sntc.station_etat not null default 'normal',
  actif           boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

comment on table sntc.stations is 'Stations-service suivies par le système';
comment on column sntc.stations.etat is 'État courant recalculé par trigger (vert/jaune/rouge/noir)';

-- FK différée profiles.station_id -> stations.id
alter table sntc.profiles
  add constraint profiles_station_fk
  foreign key (station_id) references sntc.stations(id) on delete set null;

-- -----------------------------------------------------------------------------
-- STOCKS  (état courant par produit et par station)
-- -----------------------------------------------------------------------------

create table sntc.stocks (
  id            uuid primary key default gen_random_uuid(),
  station_id    uuid not null references sntc.stations(id) on delete cascade,
  produit       sntc.fuel_type not null,
  -- Stock physique relevé (litres) — saisi par le gérant
  stock_physique numeric(12,2) not null default 0,
  -- Stock théorique calculé = précédent + livraisons - ventes
  stock_theorique numeric(12,2) not null default 0,
  -- Dernier écart constaté (physique - théorique)
  dernier_ecart  numeric(12,2) not null default 0,
  maj_le         timestamptz not null default now(),
  unique (station_id, produit)
);

comment on table sntc.stocks is 'Stock courant (physique + théorique) par station et produit';

-- -----------------------------------------------------------------------------
-- LIVRAISONS
-- -----------------------------------------------------------------------------

create table sntc.livraisons (
  id                uuid primary key default gen_random_uuid(),
  reference         text not null unique,        -- ex. "LIV-20260602-0001"
  qr_token          text not null unique,        -- jeton signé encodé dans le QR
  depot_id          uuid not null references sntc.depots(id),
  station_id        uuid not null references sntc.stations(id),
  chauffeur_id      uuid references sntc.profiles(id),
  produit           sntc.fuel_type not null,
  -- Volumes (litres)
  volume_charge     numeric(12,2) not null,      -- chargé au départ dépôt
  volume_recu       numeric(12,2),               -- mesuré à l'arrivée station
  immatriculation   text,                        -- plaque du camion-citerne
  statut            sntc.livraison_statut not null default 'creee',
  -- Validation départ
  depart_le         timestamptz,
  depart_lat        double precision,
  depart_lng        double precision,
  -- Validation arrivée
  arrivee_le        timestamptz,
  arrivee_lat       double precision,
  arrivee_lng       double precision,
  photo_arrivee_url text,                         -- photo horodatée obligatoire
  -- Métadonnées
  cree_par          uuid references sntc.profiles(id),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

comment on table sntc.livraisons is 'Bons de livraison dépôt -> station, traçés par QR + GPS';
comment on column sntc.livraisons.qr_token is 'Jeton unique signé encodé dans le QR Code (anti-falsification)';

-- Trace GPS détaillée pendant l'acheminement (points périodiques)
create table sntc.livraison_positions (
  id            bigserial primary key,
  livraison_id  uuid not null references sntc.livraisons(id) on delete cascade,
  latitude      double precision not null,
  longitude     double precision not null,
  vitesse_kmh   numeric(6,2),
  capte_le      timestamptz not null default now()
);

create index idx_positions_livraison on sntc.livraison_positions(livraison_id, capte_le);

-- -----------------------------------------------------------------------------
-- VENTES
-- -----------------------------------------------------------------------------

create table sntc.ventes (
  id            uuid primary key default gen_random_uuid(),
  station_id    uuid not null references sntc.stations(id) on delete cascade,
  produit       sntc.fuel_type not null,
  volume        numeric(12,2) not null check (volume > 0),  -- litres vendus
  prix_unitaire numeric(10,2),                               -- FCFA / litre (optionnel)
  -- Identifiant client local pour idempotence de la synchro hors-ligne
  client_uuid   uuid,
  vendue_le     timestamptz not null default now(),
  saisie_par    uuid references sntc.profiles(id),
  created_at    timestamptz not null default now(),
  unique (station_id, client_uuid)   -- évite les doublons de synchro
);

comment on table sntc.ventes is 'Ventes saisies par les gérants (sync hors-ligne idempotente)';
comment on column sntc.ventes.client_uuid is 'UUID généré côté mobile : garantit l''idempotence lors de la synchro';

-- -----------------------------------------------------------------------------
-- ALERTES
-- -----------------------------------------------------------------------------

create table sntc.alertes (
  id            uuid primary key default gen_random_uuid(),
  station_id    uuid references sntc.stations(id) on delete cascade,
  livraison_id  uuid references sntc.livraisons(id) on delete cascade,
  type          sntc.alerte_type not null,
  severite      sntc.alerte_severite not null default 'attention',
  produit       sntc.fuel_type,
  message       text not null,
  valeur        numeric(12,2),       -- valeur déclenchante (écart, autonomie...)
  -- Cycle de vie
  resolue       boolean not null default false,
  resolue_par   uuid references sntc.profiles(id),
  resolue_le    timestamptz,
  created_at    timestamptz not null default now()
);

comment on table sntc.alertes is 'Alertes automatiques (écarts, ruptures, livraisons non validées)';

-- Empêche les doublons d'alertes ouvertes du même type pour une même station/produit
create unique index uq_alerte_ouverte
  on sntc.alertes (station_id, type, coalesce(produit, 'essence'::sntc.fuel_type))
  where resolue = false and station_id is not null;

-- -----------------------------------------------------------------------------
-- INSPECTIONS & INFRACTIONS  (module contrôleur)
-- -----------------------------------------------------------------------------

create table sntc.inspections (
  id            uuid primary key default gen_random_uuid(),
  station_id    uuid not null references sntc.stations(id) on delete cascade,
  controleur_id uuid not null references sntc.profiles(id),
  -- Relevés constatés sur place
  releve_essence numeric(12,2),
  releve_gasoil  numeric(12,2),
  rapport        text,
  signature_url  text,
  effectuee_le  timestamptz not null default now(),
  created_at    timestamptz not null default now()
);

create table sntc.inspection_photos (
  id            uuid primary key default gen_random_uuid(),
  inspection_id uuid not null references sntc.inspections(id) on delete cascade,
  photo_url     text not null,
  prise_le      timestamptz not null default now()
);

create table sntc.infractions (
  id            uuid primary key default gen_random_uuid(),
  inspection_id uuid references sntc.inspections(id) on delete set null,
  station_id    uuid not null references sntc.stations(id) on delete cascade,
  controleur_id uuid not null references sntc.profiles(id),
  gravite       sntc.infraction_gravite not null default 'mineure',
  motif         text not null,           -- ex. "Rétention volontaire", "Vente hors circuit"
  description   text,
  constatee_le  timestamptz not null default now(),
  created_at    timestamptz not null default now()
);

comment on table sntc.infractions is 'Infractions relevées par les contrôleurs (rétention, vente hors circuit...)';

-- -----------------------------------------------------------------------------
-- JOURNAL D'AUDIT  (traçabilité réglementaire)
-- -----------------------------------------------------------------------------

create table sntc.audit_log (
  id          bigserial primary key,
  acteur_id   uuid,
  action      text not null,           -- ex. "livraison.arrivee_validee"
  table_cible text,
  cible_id    text,
  donnees     jsonb,
  ip          inet,
  created_at  timestamptz not null default now()
);

create index idx_audit_acteur on sntc.audit_log(acteur_id, created_at desc);

-- -----------------------------------------------------------------------------
-- INDEX DE PERFORMANCE
-- -----------------------------------------------------------------------------

create index idx_stations_region   on sntc.stations(region_id);
create index idx_stations_etat     on sntc.stations(etat);
create index idx_ventes_station    on sntc.ventes(station_id, vendue_le desc);
create index idx_livraisons_station on sntc.livraisons(station_id, created_at desc);
create index idx_livraisons_statut on sntc.livraisons(statut);
create index idx_alertes_ouvertes  on sntc.alertes(station_id) where resolue = false;
create index idx_inspections_station on sntc.inspections(station_id, effectuee_le desc);

-- >>>>>>>>>>>>>>>>>>>>>>>>  migrations/0003_functions_triggers.sql  <<<<<<<<<<<<<<<<<<<<<<<<

-- =============================================================================
-- SNTC — Migration 0003 — Fonctions & déclencheurs (logique métier)
-- =============================================================================
-- Cœur du système : calcul automatique du stock théorique, détection des
-- écarts, recalcul de l'état des stations et génération des alertes.
-- Tout est exécuté côté base pour garantir la cohérence même en cas de
-- synchronisation hors-ligne désordonnée.
-- -----------------------------------------------------------------------------

set search_path = sntc, public;

-- -----------------------------------------------------------------------------
-- HELPERS : rôle de l'appelant (lus depuis le JWT)
-- -----------------------------------------------------------------------------

-- NB : nommée `role_courant` car `current_role` est un mot réservé SQL.
create or replace function sntc.role_courant()
returns sntc.user_role
language sql stable
as $$
  select coalesce(
    (auth.jwt() -> 'app_metadata' ->> 'role')::sntc.user_role,
    (select role from sntc.profiles where id = auth.uid())
  );
$$;

create or replace function sntc.current_station()
returns uuid
language sql stable
as $$
  select station_id from sntc.profiles where id = auth.uid();
$$;

create or replace function sntc.is_admin()
returns boolean language sql stable as $$
  select sntc.role_courant() = 'admin_national';
$$;

create or replace function sntc.is_controleur()
returns boolean language sql stable as $$
  select sntc.role_courant() in ('admin_national', 'controleur');
$$;

-- -----------------------------------------------------------------------------
-- updated_at automatique
-- -----------------------------------------------------------------------------

create or replace function sntc.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_profiles_touch  before update on sntc.profiles
  for each row execute function sntc.touch_updated_at();
create trigger trg_stations_touch  before update on sntc.stations
  for each row execute function sntc.touch_updated_at();
create trigger trg_livraisons_touch before update on sntc.livraisons
  for each row execute function sntc.touch_updated_at();

-- -----------------------------------------------------------------------------
-- GÉNÉRATION DES RÉFÉRENCES & JETONS QR
-- -----------------------------------------------------------------------------

-- Référence lisible : LIV-AAAAMMJJ-NNNN (compteur quotidien)
create sequence if not exists sntc.seq_livraison_jour;

create or replace function sntc.generer_reference_livraison()
returns trigger language plpgsql as $$
declare
  v_num int;
begin
  if new.reference is null then
    v_num := nextval('sntc.seq_livraison_jour');
    new.reference := 'LIV-' || to_char(now(), 'YYYYMMDD') || '-' || lpad(v_num::text, 4, '0');
  end if;
  if new.qr_token is null then
    -- Jeton opaque et non devinable, encodé ensuite dans le QR Code
    new.qr_token := encode(gen_random_bytes(24), 'hex');
  end if;
  return new;
end;
$$;

create trigger trg_livraison_reference
  before insert on sntc.livraisons
  for each row execute function sntc.generer_reference_livraison();

-- -----------------------------------------------------------------------------
-- CŒUR : recalcul du stock théorique d'une station/produit
-- Stock théorique = stock initial + Σ livraisons reçues - Σ ventes
-- -----------------------------------------------------------------------------

create or replace function sntc.recalculer_stock(p_station uuid, p_produit sntc.fuel_type)
returns void language plpgsql
security definer set search_path = sntc, public
as $$
declare
  v_livraisons numeric(12,2);
  v_ventes     numeric(12,2);
  v_physique   numeric(12,2);
  v_theorique  numeric(12,2);
  v_ecart      numeric(12,2);
begin
  -- Volumes effectivement réceptionnés
  select coalesce(sum(coalesce(volume_recu, volume_charge)), 0)
    into v_livraisons
    from sntc.livraisons
   where station_id = p_station
     and produit = p_produit
     and statut = 'arrivee_validee';

  -- Volumes vendus
  select coalesce(sum(volume), 0)
    into v_ventes
    from sntc.ventes
   where station_id = p_station
     and produit = p_produit;

  -- Stock physique courant (dernier relevé du gérant)
  select coalesce(stock_physique, 0)
    into v_physique
    from sntc.stocks
   where station_id = p_station and produit = p_produit;

  -- Théorique : on part du flux net. Le stock physique sert de référence
  -- d'ouverture implicite via dernier_ecart cumulé ; ici on calcule le net.
  v_theorique := v_livraisons - v_ventes;
  v_ecart     := round(v_physique - v_theorique, 2);

  insert into sntc.stocks (station_id, produit, stock_physique, stock_theorique, dernier_ecart, maj_le)
  values (p_station, p_produit, v_physique, v_theorique, v_ecart, now())
  on conflict (station_id, produit) do update
    set stock_theorique = excluded.stock_theorique,
        dernier_ecart   = excluded.dernier_ecart,
        maj_le          = now();

  -- Déclenche la réévaluation de l'état + alertes
  perform sntc.evaluer_station(p_station);
end;
$$;

-- -----------------------------------------------------------------------------
-- ÉVALUATION DE L'ÉTAT D'UNE STATION + génération d'alertes
-- Couleurs : vert/jaune/rouge/noir
-- -----------------------------------------------------------------------------

create or replace function sntc.evaluer_station(p_station uuid)
returns void language plpgsql
security definer set search_path = sntc, public
as $$
declare
  s            sntc.stations%rowtype;
  r            record;
  v_etat       sntc.station_etat := 'normal';
  v_rupture    boolean := false;
  v_faible     boolean := false;
  v_derniere_vente timestamptz;
  v_actif_24h  boolean;
begin
  select * into s from sntc.stations where id = p_station;
  if not found then return; end if;

  -- Parcours des produits de la station
  for r in
    select st.produit, st.stock_physique, st.dernier_ecart,
           case st.produit when 'essence' then s.seuil_faible_essence
                           else s.seuil_faible_gasoil end as seuil
      from sntc.stocks st
     where st.station_id = p_station
  loop
    -- Rupture totale
    if r.stock_physique <= 0 then
      v_rupture := true;
      perform sntc.lever_alerte(p_station, null, 'rupture_totale', 'critique',
        r.produit, 'Rupture totale ' || r.produit, 0);
    -- Rupture imminente / stock faible
    elsif r.stock_physique <= r.seuil then
      v_faible := true;
      perform sntc.lever_alerte(p_station, null, 'rupture_imminente', 'attention',
        r.produit, 'Stock ' || r.produit || ' faible (' || r.stock_physique || ' L)', r.stock_physique);
    else
      -- Stock revenu à la normale : on résout les alertes de rupture liées
      perform sntc.resoudre_alertes(p_station, r.produit, array['rupture_totale','rupture_imminente']);
    end if;

    -- Écart de stock au-delà de la tolérance
    if abs(r.dernier_ecart) > s.seuil_ecart then
      perform sntc.lever_alerte(p_station, null, 'ecart_stock', 'critique',
        r.produit, 'Écart de stock ' || r.produit || ' : ' || r.dernier_ecart || ' L', r.dernier_ecart);
    else
      perform sntc.resoudre_alertes(p_station, r.produit, array['ecart_stock']);
    end if;
  end loop;

  -- Activité : dernière vente
  select max(vendue_le) into v_derniere_vente
    from sntc.ventes where station_id = p_station;

  v_actif_24h := v_derniere_vente is not null and v_derniere_vente > now() - interval '24 hours';

  if not v_actif_24h then
    perform sntc.lever_alerte(p_station, null, 'sans_vente_24h', 'attention',
      null, 'Aucune vente depuis plus de 24h', null);
  else
    perform sntc.resoudre_alertes(p_station, null, array['sans_vente_24h']);
  end if;

  -- Détermination de la couleur (priorité : noir > rouge > jaune > vert)
  if not s.actif then
    v_etat := 'inactive';
  elsif v_derniere_vente is null or v_derniere_vente < now() - interval '72 hours' then
    v_etat := 'inactive';        -- noir : station qui ne remonte plus rien
  elsif v_rupture then
    v_etat := 'rupture';
  elsif v_faible then
    v_etat := 'faible';
  else
    v_etat := 'normal';
  end if;

  update sntc.stations set etat = v_etat where id = p_station and etat is distinct from v_etat;
end;
$$;

-- -----------------------------------------------------------------------------
-- GESTION DES ALERTES (lever / résoudre, idempotent)
-- -----------------------------------------------------------------------------

create or replace function sntc.lever_alerte(
  p_station uuid, p_livraison uuid, p_type sntc.alerte_type,
  p_severite sntc.alerte_severite, p_produit sntc.fuel_type,
  p_message text, p_valeur numeric
) returns void language plpgsql
security definer set search_path = sntc, public
as $$
begin
  -- On ne crée pas de doublon si une alerte ouverte du même type existe déjà
  if exists (
    select 1 from sntc.alertes
     where resolue = false
       and type = p_type
       and station_id is not distinct from p_station
       and produit is not distinct from p_produit
  ) then
    return;
  end if;

  insert into sntc.alertes (station_id, livraison_id, type, severite, produit, message, valeur)
  values (p_station, p_livraison, p_type, p_severite, p_produit, p_message, p_valeur);
end;
$$;

create or replace function sntc.resoudre_alertes(
  p_station uuid, p_produit sntc.fuel_type, p_types text[]
) returns void language plpgsql
security definer set search_path = sntc, public
as $$
begin
  update sntc.alertes
     set resolue = true, resolue_le = now()
   where resolue = false
     and station_id = p_station
     and type = any (p_types::sntc.alerte_type[])
     and (p_produit is null or produit is not distinct from p_produit);
end;
$$;

-- -----------------------------------------------------------------------------
-- DÉCLENCHEURS : toute vente ou livraison réceptionnée recalcule le stock
-- -----------------------------------------------------------------------------

create or replace function sntc.trg_vente_recalcul()
returns trigger language plpgsql
security definer set search_path = sntc, public
as $$
begin
  perform sntc.recalculer_stock(new.station_id, new.produit);
  return new;
end;
$$;

create trigger trg_vente_after_insert
  after insert on sntc.ventes
  for each row execute function sntc.trg_vente_recalcul();

create or replace function sntc.trg_livraison_recalcul()
returns trigger language plpgsql
security definer set search_path = sntc, public
as $$
begin
  if new.statut = 'arrivee_validee'
     and (tg_op = 'INSERT' or old.statut is distinct from 'arrivee_validee') then
    -- Écart livraison : volume reçu vs chargé
    if new.volume_recu is not null and abs(new.volume_recu - new.volume_charge) > 50 then
      perform sntc.lever_alerte(new.station_id, new.id, 'ecart_stock', 'critique',
        new.produit,
        'Écart livraison ' || new.reference || ' : reçu ' || new.volume_recu
          || ' / chargé ' || new.volume_charge || ' L',
        new.volume_recu - new.volume_charge);
    end if;
    perform sntc.recalculer_stock(new.station_id, new.produit);
  end if;
  return new;
end;
$$;

create trigger trg_livraison_after_change
  after insert or update of statut on sntc.livraisons
  for each row execute function sntc.trg_livraison_recalcul();

-- Mise à jour manuelle du stock physique par le gérant -> recalcul
create or replace function sntc.trg_stock_physique_recalcul()
returns trigger language plpgsql
security definer set search_path = sntc, public
as $$
begin
  if new.stock_physique is distinct from old.stock_physique then
    perform sntc.recalculer_stock(new.station_id, new.produit);
  end if;
  return new;
end;
$$;

create trigger trg_stock_after_update
  after update of stock_physique on sntc.stocks
  for each row execute function sntc.trg_stock_physique_recalcul();

-- -----------------------------------------------------------------------------
-- TÂCHE PÉRIODIQUE : balayage global (appelée par pg_cron ou edge function)
-- Détecte livraisons non validées + réévalue toutes les stations.
-- -----------------------------------------------------------------------------

create or replace function sntc.balayage_alertes()
returns integer language plpgsql
security definer set search_path = sntc, public
as $$
declare
  l record;
  st record;
  n int := 0;
begin
  -- Livraisons parties mais jamais réceptionnées après 12h
  for l in
    select * from sntc.livraisons
     where statut in ('depart_valide', 'en_route')
       and depart_le < now() - interval '12 hours'
  loop
    perform sntc.lever_alerte(l.station_id, l.id, 'livraison_non_validee', 'critique',
      l.produit, 'Livraison ' || l.reference || ' non validée à l''arrivée', null);
    n := n + 1;
  end loop;

  -- Réévalue chaque station active
  for st in select id from sntc.stations where actif loop
    perform sntc.evaluer_station(st.id);
  end loop;

  return n;
end;
$$;

-- >>>>>>>>>>>>>>>>>>>>>>>>  migrations/0004_rls.sql  <<<<<<<<<<<<<<<<<<<<<<<<

-- =============================================================================
-- SNTC — Migration 0004 — Sécurité au niveau ligne (RLS) & rôles
-- =============================================================================
-- Modèle d'accès :
--   admin_national : lecture/écriture sur tout le pays
--   controleur     : lecture sur tout + écriture inspections/infractions
--   gerant         : lecture/écriture limitées à SA station
--   chauffeur      : lecture/écriture sur SES livraisons
-- -----------------------------------------------------------------------------

set search_path = sntc, public;

-- Active RLS partout
alter table sntc.profiles            enable row level security;
alter table sntc.depots              enable row level security;
alter table sntc.stations            enable row level security;
alter table sntc.stocks              enable row level security;
alter table sntc.livraisons          enable row level security;
alter table sntc.livraison_positions enable row level security;
alter table sntc.ventes              enable row level security;
alter table sntc.alertes             enable row level security;
alter table sntc.inspections         enable row level security;
alter table sntc.inspection_photos   enable row level security;
alter table sntc.infractions         enable row level security;
alter table sntc.regions             enable row level security;
alter table sntc.audit_log           enable row level security;

-- Donne l'usage du schéma aux rôles Supabase
grant usage on schema sntc to anon, authenticated, service_role;
grant select, insert, update, delete on all tables in schema sntc to authenticated;
grant select on all tables in schema sntc to anon;
grant usage, select on all sequences in schema sntc to authenticated;
alter default privileges in schema sntc grant select, insert, update, delete on tables to authenticated;

-- -----------------------------------------------------------------------------
-- RÉFÉRENTIELS (lecture pour tous les connectés)
-- -----------------------------------------------------------------------------

create policy regions_read on sntc.regions
  for select to authenticated using (true);

create policy depots_read on sntc.depots
  for select to authenticated using (true);

create policy depots_admin on sntc.depots
  for all to authenticated using (sntc.is_admin()) with check (sntc.is_admin());

-- -----------------------------------------------------------------------------
-- PROFILES
-- -----------------------------------------------------------------------------

-- Chacun lit son propre profil ; admin/contrôleur lisent tout
create policy profiles_read on sntc.profiles
  for select to authenticated
  using (id = auth.uid() or sntc.is_controleur());

-- Seul l'admin gère les comptes ; chacun met à jour ses infos non sensibles
create policy profiles_admin on sntc.profiles
  for all to authenticated
  using (sntc.is_admin()) with check (sntc.is_admin());

create policy profiles_self_update on sntc.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid() and role = (select role from sntc.profiles where id = auth.uid()));

-- -----------------------------------------------------------------------------
-- STATIONS
-- -----------------------------------------------------------------------------

-- Lecture : admin/contrôleur tout ; gérant/chauffeur leur station
create policy stations_read on sntc.stations
  for select to authenticated
  using (sntc.is_controleur() or id = sntc.current_station());

create policy stations_admin on sntc.stations
  for all to authenticated
  using (sntc.is_admin()) with check (sntc.is_admin());

-- Le gérant peut ajuster les seuils de SA station
create policy stations_gerant_update on sntc.stations
  for update to authenticated
  using (id = sntc.current_station() and sntc.role_courant() = 'gerant')
  with check (id = sntc.current_station());

-- -----------------------------------------------------------------------------
-- STOCKS
-- -----------------------------------------------------------------------------

create policy stocks_read on sntc.stocks
  for select to authenticated
  using (sntc.is_controleur() or station_id = sntc.current_station());

-- Le gérant relève le stock physique de sa station
create policy stocks_gerant_write on sntc.stocks
  for all to authenticated
  using (station_id = sntc.current_station() or sntc.is_admin())
  with check (station_id = sntc.current_station() or sntc.is_admin());

-- -----------------------------------------------------------------------------
-- LIVRAISONS
-- -----------------------------------------------------------------------------

-- Lecture : admin/contrôleur tout ; gérant = livraisons vers sa station ;
-- chauffeur = ses propres livraisons
create policy livraisons_read on sntc.livraisons
  for select to authenticated
  using (
    sntc.is_controleur()
    or station_id = sntc.current_station()
    or chauffeur_id = auth.uid()
  );

-- Création : admin (planification) ou gérant de la station destinataire
create policy livraisons_create on sntc.livraisons
  for insert to authenticated
  with check (sntc.is_admin() or station_id = sntc.current_station());

-- Mise à jour : admin ; chauffeur assigné (départ/positions/arrivée) ;
-- gérant destinataire (validation arrivée)
create policy livraisons_update on sntc.livraisons
  for update to authenticated
  using (sntc.is_admin() or chauffeur_id = auth.uid() or station_id = sntc.current_station())
  with check (sntc.is_admin() or chauffeur_id = auth.uid() or station_id = sntc.current_station());

create policy positions_read on sntc.livraison_positions
  for select to authenticated
  using (
    sntc.is_controleur()
    or exists (select 1 from sntc.livraisons l
                where l.id = livraison_id
                  and (l.chauffeur_id = auth.uid() or l.station_id = sntc.current_station()))
  );

create policy positions_insert on sntc.livraison_positions
  for insert to authenticated
  with check (
    exists (select 1 from sntc.livraisons l
             where l.id = livraison_id and l.chauffeur_id = auth.uid())
  );

-- -----------------------------------------------------------------------------
-- VENTES
-- -----------------------------------------------------------------------------

create policy ventes_read on sntc.ventes
  for select to authenticated
  using (sntc.is_controleur() or station_id = sntc.current_station());

-- Le gérant saisit les ventes de SA station
create policy ventes_gerant_insert on sntc.ventes
  for insert to authenticated
  with check (station_id = sntc.current_station() or sntc.is_admin());

-- -----------------------------------------------------------------------------
-- ALERTES
-- -----------------------------------------------------------------------------

create policy alertes_read on sntc.alertes
  for select to authenticated
  using (sntc.is_controleur() or station_id = sntc.current_station());

-- Résolution : admin/contrôleur, ou gérant de la station
create policy alertes_resolve on sntc.alertes
  for update to authenticated
  using (sntc.is_controleur() or station_id = sntc.current_station())
  with check (sntc.is_controleur() or station_id = sntc.current_station());

-- -----------------------------------------------------------------------------
-- INSPECTIONS & INFRACTIONS (contrôleurs)
-- -----------------------------------------------------------------------------

create policy inspections_read on sntc.inspections
  for select to authenticated
  using (sntc.is_controleur() or station_id = sntc.current_station());

create policy inspections_write on sntc.inspections
  for all to authenticated
  using (sntc.is_controleur())
  with check (sntc.is_controleur() and controleur_id = auth.uid());

create policy inspection_photos_rw on sntc.inspection_photos
  for all to authenticated
  using (sntc.is_controleur())
  with check (sntc.is_controleur());

create policy infractions_read on sntc.infractions
  for select to authenticated
  using (sntc.is_controleur() or station_id = sntc.current_station());

create policy infractions_write on sntc.infractions
  for all to authenticated
  using (sntc.is_controleur())
  with check (sntc.is_controleur() and controleur_id = auth.uid());

-- -----------------------------------------------------------------------------
-- AUDIT LOG (lecture admin seul ; écriture via service_role / triggers)
-- -----------------------------------------------------------------------------

create policy audit_read on sntc.audit_log
  for select to authenticated using (sntc.is_admin());

-- -----------------------------------------------------------------------------
-- PROVISIONNEMENT AUTOMATIQUE DU PROFIL À L'INSCRIPTION
-- -----------------------------------------------------------------------------

create or replace function sntc.handle_new_user()
returns trigger language plpgsql
security definer set search_path = sntc, public
as $$
begin
  insert into sntc.profiles (id, role, nom_complet, telephone, station_id)
  values (
    new.id,
    coalesce((new.raw_app_meta_data ->> 'role')::sntc.user_role, 'gerant'),
    coalesce(new.raw_user_meta_data ->> 'nom_complet', new.email),
    new.raw_user_meta_data ->> 'telephone',
    (new.raw_app_meta_data ->> 'station_id')::uuid
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function sntc.handle_new_user();

-- >>>>>>>>>>>>>>>>>>>>>>>>  migrations/0005_views.sql  <<<<<<<<<<<<<<<<<<<<<<<<

-- =============================================================================
-- SNTC — Migration 0005 — Vues du tableau de bord gouvernemental
-- =============================================================================
-- Vues exposées à l'API REST (PostgREST). Elles héritent du RLS des tables
-- sous-jacentes grâce à security_invoker.
-- -----------------------------------------------------------------------------

set search_path = sntc, public;

-- -----------------------------------------------------------------------------
-- Vue carte : tout ce qu'il faut pour afficher une station sur Mapbox
-- -----------------------------------------------------------------------------

create or replace view sntc.v_carte_stations
with (security_invoker = true) as
select
  s.id,
  s.code,
  s.nom,
  s.enseigne,
  s.latitude,
  s.longitude,
  s.etat,                              -- pilote la couleur du marqueur
  r.nom as region,
  s.commune,
  coalesce(se.stock_physique, 0) as stock_essence,
  coalesce(sg.stock_physique, 0) as stock_gasoil,
  (select count(*) from sntc.alertes a
    where a.station_id = s.id and a.resolue = false) as alertes_ouvertes,
  (select max(v.vendue_le) from sntc.ventes v where v.station_id = s.id) as derniere_vente
from sntc.stations s
left join sntc.regions r on r.id = s.region_id
left join sntc.stocks se on se.station_id = s.id and se.produit = 'essence'
left join sntc.stocks sg on sg.station_id = s.id and sg.produit = 'gasoil';

-- -----------------------------------------------------------------------------
-- Indicateurs nationaux (KPIs du tableau de bord)
-- -----------------------------------------------------------------------------

create or replace view sntc.v_dashboard_national
with (security_invoker = true) as
select
  (select coalesce(sum(stock_physique), 0) from sntc.stocks where produit = 'essence') as stock_national_essence,
  (select coalesce(sum(stock_physique), 0) from sntc.stocks where produit = 'gasoil')  as stock_national_gasoil,
  (select count(*) from sntc.stations where actif) as nb_stations,
  (select count(*) from sntc.stations where etat = 'rupture') as stations_rupture,
  (select count(*) from sntc.stations where etat = 'faible')  as stations_faibles,
  (select count(*) from sntc.stations where etat = 'inactive') as stations_inactives,
  (select count(*) from sntc.livraisons where created_at::date = current_date) as livraisons_jour,
  (select count(*) from sntc.livraisons
     where statut in ('depart_valide','en_route')) as livraisons_en_cours,
  (select count(*) from sntc.alertes where resolue = false and severite = 'critique') as alertes_critiques,
  (select count(distinct station_id) from sntc.alertes
     where resolue = false and type in ('ecart_stock','sans_vente_24h')) as stations_suspectes;

-- -----------------------------------------------------------------------------
-- Stock agrégé par région
-- -----------------------------------------------------------------------------

create or replace view sntc.v_stock_par_region
with (security_invoker = true) as
select
  r.id as region_id,
  r.nom as region,
  count(distinct s.id) as nb_stations,
  coalesce(sum(st.stock_physique) filter (where st.produit = 'essence'), 0) as stock_essence,
  coalesce(sum(st.stock_physique) filter (where st.produit = 'gasoil'), 0)  as stock_gasoil,
  count(distinct s.id) filter (where s.etat = 'rupture') as stations_rupture
from sntc.regions r
left join sntc.stations s on s.region_id = r.id and s.actif
left join sntc.stocks st on st.station_id = s.id
group by r.id, r.nom
order by r.nom;

-- -----------------------------------------------------------------------------
-- Stations suspectes (écarts répétés, ruptures fréquentes, sans-vente)
-- -----------------------------------------------------------------------------

create or replace view sntc.v_stations_suspectes
with (security_invoker = true) as
select
  s.id, s.code, s.nom, r.nom as region, s.etat,
  count(a.*) filter (where a.type = 'ecart_stock')   as nb_ecarts,
  count(a.*) filter (where a.type = 'sans_vente_24h') as nb_sans_vente,
  count(i.*) as nb_infractions,
  max(a.created_at) as derniere_alerte
from sntc.stations s
left join sntc.regions r on r.id = s.region_id
left join sntc.alertes a on a.station_id = s.id
left join sntc.infractions i on i.station_id = s.id
group by s.id, s.code, s.nom, r.nom, s.etat
having count(a.*) filter (where a.type in ('ecart_stock','sans_vente_24h')) > 0
    or count(i.*) > 0
order by nb_infractions desc, nb_ecarts desc;

-- -----------------------------------------------------------------------------
-- Consommation journalière par station (module ventes)
-- -----------------------------------------------------------------------------

create or replace view sntc.v_consommation_journaliere
with (security_invoker = true) as
select
  station_id,
  produit,
  vendue_le::date as jour,
  count(*)        as nb_ventes,
  sum(volume)     as volume_total,
  round(avg(volume), 2) as volume_moyen
from sntc.ventes
group by station_id, produit, vendue_le::date;

grant select on sntc.v_carte_stations,
               sntc.v_dashboard_national,
               sntc.v_stock_par_region,
               sntc.v_stations_suspectes,
               sntc.v_consommation_journaliere
  to authenticated;
