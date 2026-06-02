-- =============================================================================
-- SNTC — Jeu de données de démonstration (pilote Bamako)
-- =============================================================================
-- ORDRE D'EXÉCUTION IMPORTANT :
--   1. supabase db push / migrations    (crée le schéma)
--   2. scripts/seed_users.ts            (crée les comptes auth.users ; le
--      trigger handle_new_user crée alors automatiquement les profils)
--   3. CE FICHIER                       psql "$DATABASE_URL" -f demo_bamako.sql
--
-- `sntc.profiles.id` référence `auth.users(id)` : les comptes DOIVENT exister
-- avant ce seed. Les UUID ci-dessous sont déterministes et correspondent à
-- ceux produits par seed_users.ts. L'insert des profils utilise ON CONFLICT
-- DO UPDATE (les profils ont déjà été créés par le trigger).
-- -----------------------------------------------------------------------------

set search_path = sntc, public;

-- --- Régions du Mali --------------------------------------------------------
insert into sntc.regions (id, nom, chef_lieu) values
  (1, 'Bamako (District)', 'Bamako'),
  (2, 'Kayes', 'Kayes'),
  (3, 'Koulikoro', 'Koulikoro'),
  (4, 'Sikasso', 'Sikasso'),
  (5, 'Ségou', 'Ségou'),
  (6, 'Mopti', 'Mopti'),
  (7, 'Tombouctou', 'Tombouctou'),
  (8, 'Gao', 'Gao'),
  (9, 'Kidal', 'Kidal')
on conflict (id) do nothing;

-- --- Dépôts pétroliers ------------------------------------------------------
insert into sntc.depots (id, nom, region_id, adresse, latitude, longitude) values
  ('11111111-0000-0000-0000-000000000001', 'Dépôt EDM Bamako-Sotuba', 1, 'Sotuba, Bamako', 12.6650, -7.9520),
  ('11111111-0000-0000-0000-000000000002', 'Dépôt Ouest Kati',        3, 'Route de Kati',  12.7450, -8.0730)
on conflict (id) do nothing;

-- --- Stations-service (Bamako, coordonnées réalistes) -----------------------
insert into sntc.stations
  (id, code, nom, enseigne, region_id, commune, adresse, latitude, longitude,
   capacite_essence, capacite_gasoil, seuil_faible_essence, seuil_faible_gasoil, seuil_ecart, etat)
values
  ('22222222-0000-0000-0000-000000000001', 'BKO-ACI-001', 'Station ACI 2000',      'Total',  1, 'Commune IV', 'ACI 2000, Hamdallaye', 12.6280, -8.0490, 30000, 40000, 2500, 3500, 250, 'normal'),
  ('22222222-0000-0000-0000-000000000002', 'BKO-HIP-002', 'Station Hippodrome',    'Oryx',   1, 'Commune II', 'Hippodrome',           12.6480, -7.9890, 25000, 35000, 2000, 3000, 200, 'normal'),
  ('22222222-0000-0000-0000-000000000003', 'BKO-BAD-003', 'Station Badalabougou',  'Shell',  1, 'Commune V',  'Badalabougou',         12.6160, -8.0010, 20000, 30000, 1800, 2500, 200, 'faible'),
  ('22222222-0000-0000-0000-000000000004', 'BKO-MAG-004', 'Station Magnambougou',  'Total',  1, 'Commune VI', 'Magnambougou',         12.6010, -7.9450, 28000, 38000, 2200, 3200, 250, 'rupture'),
  ('22222222-0000-0000-0000-000000000005', 'BKO-DJI-005', 'Station Djicoroni',     'Oilibya',1, 'Commune IV', 'Djicoroni Para',       12.6390, -8.0290, 22000, 32000, 2000, 3000, 200, 'normal'),
  ('22222222-0000-0000-0000-000000000006', 'BKO-KAL-006', 'Station Kalaban Coura', 'Oryx',   1, 'Commune V',  'Kalaban Coura',        12.5890, -8.0040, 24000, 34000, 2000, 3000, 200, 'inactive')
on conflict (id) do nothing;

-- --- Profils (liés aux comptes auth créés par seed_users.ts) ----------------
-- admin_national / controleur / gerant(x2) / chauffeur
insert into sntc.profiles (id, role, nom_complet, telephone, region_id, station_id) values
  ('33333333-0000-0000-0000-000000000001', 'admin_national', 'Aminata Traoré',  '+22370000001', 1, null),
  ('33333333-0000-0000-0000-000000000002', 'controleur',     'Modibo Keïta',    '+22370000002', 1, null),
  ('33333333-0000-0000-0000-000000000003', 'gerant',         'Fatoumata Diarra','+22370000003', 1, '22222222-0000-0000-0000-000000000001'),
  ('33333333-0000-0000-0000-000000000004', 'gerant',         'Ousmane Coulibaly','+22370000004',1, '22222222-0000-0000-0000-000000000004'),
  ('33333333-0000-0000-0000-000000000005', 'chauffeur',      'Ibrahim Sangaré', '+22370000005', 1, '22222222-0000-0000-0000-000000000001')
on conflict (id) do update set role = excluded.role, station_id = excluded.station_id;

-- --- Stock initial (physique) -----------------------------------------------
insert into sntc.stocks (station_id, produit, stock_physique) values
  ('22222222-0000-0000-0000-000000000001', 'essence', 18000),
  ('22222222-0000-0000-0000-000000000001', 'gasoil',  26000),
  ('22222222-0000-0000-0000-000000000002', 'essence', 12000),
  ('22222222-0000-0000-0000-000000000002', 'gasoil',  20000),
  ('22222222-0000-0000-0000-000000000003', 'essence', 1500),   -- sous seuil -> jaune
  ('22222222-0000-0000-0000-000000000003', 'gasoil',  9000),
  ('22222222-0000-0000-0000-000000000004', 'essence', 0),       -- rupture -> rouge
  ('22222222-0000-0000-0000-000000000004', 'gasoil',  500),
  ('22222222-0000-0000-0000-000000000005', 'essence', 15000),
  ('22222222-0000-0000-0000-000000000005', 'gasoil',  22000),
  ('22222222-0000-0000-0000-000000000006', 'essence', 8000),
  ('22222222-0000-0000-0000-000000000006', 'gasoil',  11000)
on conflict (station_id, produit) do update set stock_physique = excluded.stock_physique;

-- --- Livraisons de démonstration --------------------------------------------
insert into sntc.livraisons
  (id, reference, qr_token, depot_id, station_id, chauffeur_id, produit,
   volume_charge, volume_recu, immatriculation, statut, depart_le, depart_lat, depart_lng,
   arrivee_le, arrivee_lat, arrivee_lng, cree_par)
values
  -- Livraison terminée, conforme
  ('44444444-0000-0000-0000-000000000001', 'LIV-20260601-0001', 'demo_token_aa01',
   '11111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000001',
   '33333333-0000-0000-0000-000000000005', 'gasoil',
   15000, 14980, 'BKO-4521-MD', 'arrivee_validee',
   '2026-06-01 06:30:00+00', 12.6650, -7.9520,
   '2026-06-01 08:15:00+00', 12.6280, -8.0490,
   '33333333-0000-0000-0000-000000000001'),
  -- Livraison en cours (sera marquée non validée par le balayage si >12h)
  ('44444444-0000-0000-0000-000000000002', 'LIV-20260602-0001', 'demo_token_bb02',
   '11111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000004',
   '33333333-0000-0000-0000-000000000005', 'essence',
   12000, null, 'BKO-7788-MD', 'en_route',
   now() - interval '13 hours', 12.6650, -7.9520,
   null, null, null,
   '33333333-0000-0000-0000-000000000001'),
  -- Livraison créée, QR émis, départ non encore validé
  ('44444444-0000-0000-0000-000000000003', 'LIV-20260602-0002', 'demo_token_cc03',
   '11111111-0000-0000-0000-000000000002', '22222222-0000-0000-0000-000000000002',
   null, 'gasoil',
   18000, null, null, 'creee',
   null, null, null, null, null, null,
   '33333333-0000-0000-0000-000000000001')
on conflict (id) do nothing;

-- --- Ventes de démonstration (réparties sur 2 jours) ------------------------
insert into sntc.ventes (station_id, produit, volume, prix_unitaire, client_uuid, vendue_le, saisie_par)
select
  '22222222-0000-0000-0000-000000000001', 'gasoil',
  (random()*60 + 20)::numeric(12,2), 775,
  gen_random_uuid(), now() - (g || ' hours')::interval,
  '33333333-0000-0000-0000-000000000003'
from generate_series(1, 12) g
on conflict do nothing;

insert into sntc.ventes (station_id, produit, volume, prix_unitaire, client_uuid, vendue_le, saisie_par)
select
  '22222222-0000-0000-0000-000000000001', 'essence',
  (random()*40 + 15)::numeric(12,2), 845,
  gen_random_uuid(), now() - (g || ' hours')::interval,
  '33333333-0000-0000-0000-000000000003'
from generate_series(1, 10) g
on conflict do nothing;

-- --- Inspection + infraction de démonstration -------------------------------
insert into sntc.inspections (id, station_id, controleur_id, releve_essence, releve_gasoil, rapport, effectuee_le)
values ('55555555-0000-0000-0000-000000000001',
        '22222222-0000-0000-0000-000000000004',
        '33333333-0000-0000-0000-000000000002',
        0, 480,
        'Station fermée en pleine journée alors que stock gasoil disponible. Suspicion de rétention.',
        now() - interval '2 hours')
on conflict (id) do nothing;

insert into sntc.infractions (inspection_id, station_id, controleur_id, gravite, motif, description)
values ('55555555-0000-0000-0000-000000000001',
        '22222222-0000-0000-0000-000000000004',
        '33333333-0000-0000-0000-000000000002',
        'grave', 'Rétention volontaire de carburant',
        'Refus de vente malgré stock disponible. Procès-verbal dressé.')
on conflict do nothing;

-- --- Recalcul global : génère stocks théoriques, états et alertes -----------
select sntc.balayage_alertes();
