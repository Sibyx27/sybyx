-- =============================================================================
-- SNTC — Données de démo « test rapide » (SANS outil en ligne de commande)
-- =============================================================================
-- Pensé pour un premier test via le SQL Editor de Supabase (navigateur), sans
-- Deno ni CLI. Ne dépend d'AUCUN compte utilisateur : les références aux
-- utilisateurs (chauffeur, gérant, contrôleur) sont laissées à NULL.
--
-- MODE D'EMPLOI :
--   1. Exécutez d'abord les migrations 0001 → 0005 dans le SQL Editor.
--   2. Exécutez CE fichier (charge 2 dépôts, 6 stations Bamako, stocks,
--      ventes et livraisons de démonstration).
--   3. Créez votre compte dans Authentication → Users → Add user.
--   4. Exécutez le bloc « PROMOTION » en bas pour devenir administrateur.
-- =============================================================================

set search_path = sntc, public;

-- --- Régions ----------------------------------------------------------------
insert into sntc.regions (id, nom, chef_lieu) values
  (1, 'Bamako (District)', 'Bamako'), (2, 'Kayes', 'Kayes'),
  (3, 'Koulikoro', 'Koulikoro'),      (4, 'Sikasso', 'Sikasso'),
  (5, 'Ségou', 'Ségou'),              (6, 'Mopti', 'Mopti'),
  (7, 'Tombouctou', 'Tombouctou'),    (8, 'Gao', 'Gao'), (9, 'Kidal', 'Kidal')
on conflict (id) do nothing;

-- --- Dépôts -----------------------------------------------------------------
insert into sntc.depots (id, nom, region_id, adresse, latitude, longitude) values
  ('11111111-0000-0000-0000-000000000001', 'Dépôt EDM Bamako-Sotuba', 1, 'Sotuba', 12.6650, -7.9520),
  ('11111111-0000-0000-0000-000000000002', 'Dépôt Ouest Kati',        3, 'Kati',   12.7450, -8.0730)
on conflict (id) do nothing;

-- --- Stations (Bamako) ------------------------------------------------------
insert into sntc.stations
  (id, code, nom, enseigne, region_id, commune, adresse, latitude, longitude,
   capacite_essence, capacite_gasoil, seuil_faible_essence, seuil_faible_gasoil, seuil_ecart, etat)
values
  ('22222222-0000-0000-0000-000000000001', 'BKO-ACI-001', 'Station ACI 2000',      'Total',  1, 'Commune IV', 'ACI 2000',       12.6280, -8.0490, 30000, 40000, 2500, 3500, 250, 'normal'),
  ('22222222-0000-0000-0000-000000000002', 'BKO-HIP-002', 'Station Hippodrome',    'Oryx',   1, 'Commune II', 'Hippodrome',     12.6480, -7.9890, 25000, 35000, 2000, 3000, 200, 'normal'),
  ('22222222-0000-0000-0000-000000000003', 'BKO-BAD-003', 'Station Badalabougou',  'Shell',  1, 'Commune V',  'Badalabougou',   12.6160, -8.0010, 20000, 30000, 1800, 2500, 200, 'faible'),
  ('22222222-0000-0000-0000-000000000004', 'BKO-MAG-004', 'Station Magnambougou',  'Total',  1, 'Commune VI', 'Magnambougou',   12.6010, -7.9450, 28000, 38000, 2200, 3200, 250, 'rupture'),
  ('22222222-0000-0000-0000-000000000005', 'BKO-DJI-005', 'Station Djicoroni',     'Oilibya',1, 'Commune IV', 'Djicoroni Para', 12.6390, -8.0290, 22000, 32000, 2000, 3000, 200, 'normal'),
  ('22222222-0000-0000-0000-000000000006', 'BKO-KAL-006', 'Station Kalaban Coura', 'Oryx',   1, 'Commune V',  'Kalaban Coura',  12.5890, -8.0040, 24000, 34000, 2000, 3000, 200, 'inactive')
on conflict (id) do nothing;

-- --- Stocks physiques initiaux ----------------------------------------------
insert into sntc.stocks (station_id, produit, stock_physique) values
  ('22222222-0000-0000-0000-000000000001', 'essence', 18000),
  ('22222222-0000-0000-0000-000000000001', 'gasoil',  26000),
  ('22222222-0000-0000-0000-000000000002', 'essence', 12000),
  ('22222222-0000-0000-0000-000000000002', 'gasoil',  20000),
  ('22222222-0000-0000-0000-000000000003', 'essence', 1500),
  ('22222222-0000-0000-0000-000000000003', 'gasoil',  9000),
  ('22222222-0000-0000-0000-000000000004', 'essence', 0),
  ('22222222-0000-0000-0000-000000000004', 'gasoil',  500),
  ('22222222-0000-0000-0000-000000000005', 'essence', 15000),
  ('22222222-0000-0000-0000-000000000005', 'gasoil',  22000),
  ('22222222-0000-0000-0000-000000000006', 'essence', 8000),
  ('22222222-0000-0000-0000-000000000006', 'gasoil',  11000)
on conflict (station_id, produit) do update set stock_physique = excluded.stock_physique;

-- --- Livraisons (sans chauffeur assigné) ------------------------------------
insert into sntc.livraisons
  (id, reference, qr_token, depot_id, station_id, produit,
   volume_charge, volume_recu, immatriculation, statut, depart_le, arrivee_le)
values
  ('44444444-0000-0000-0000-000000000001', 'LIV-20260601-0001', 'demo_token_aa01',
   '11111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000001', 'gasoil',
   15000, 14980, 'BKO-4521-MD', 'arrivee_validee', '2026-06-01 06:30:00+00', '2026-06-01 08:15:00+00'),
  ('44444444-0000-0000-0000-000000000002', 'LIV-20260602-0001', 'demo_token_bb02',
   '11111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000004', 'essence',
   12000, null, 'BKO-7788-MD', 'en_route', now() - interval '13 hours', null)
on conflict (id) do nothing;

-- --- Ventes (sans saisie_par) -----------------------------------------------
insert into sntc.ventes (station_id, produit, volume, prix_unitaire, client_uuid, vendue_le)
select '22222222-0000-0000-0000-000000000001', 'gasoil',
       (random()*60 + 20)::numeric(12,2), 775, gen_random_uuid(), now() - (g || ' hours')::interval
from generate_series(1, 12) g
on conflict do nothing;

insert into sntc.ventes (station_id, produit, volume, prix_unitaire, client_uuid, vendue_le)
select '22222222-0000-0000-0000-000000000001', 'essence',
       (random()*40 + 15)::numeric(12,2), 845, gen_random_uuid(), now() - (g || ' hours')::interval
from generate_series(1, 10) g
on conflict do nothing;

-- --- Recalcule stocks théoriques, couleurs et alertes -----------------------
select sntc.balayage_alertes();

-- =============================================================================
-- BLOC « PROMOTION » — à exécuter APRÈS avoir créé votre compte
-- =============================================================================
-- Remplacez 'vous@exemple.com' par l'email du compte créé dans
-- Authentication → Users, puis exécutez ces lignes :
--
--   -- Devenir administrateur national (accès au tableau de bord web) :
--   update sntc.profiles
--      set role = 'admin_national'
--    where id = (select id from auth.users where email = 'vous@exemple.com');
--
--   -- OU devenir gérant de la station ACI 2000 (pour tester l'app mobile) :
--   update sntc.profiles
--      set role = 'gerant',
--          station_id = '22222222-0000-0000-0000-000000000001'
--    where id = (select id from auth.users where email = 'vous@exemple.com');
-- =============================================================================
