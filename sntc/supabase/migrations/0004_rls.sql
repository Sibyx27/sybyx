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
