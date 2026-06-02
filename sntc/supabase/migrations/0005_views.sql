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
