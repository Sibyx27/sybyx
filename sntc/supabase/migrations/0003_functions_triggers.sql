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
