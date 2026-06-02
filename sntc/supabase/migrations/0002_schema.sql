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
