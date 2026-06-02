-- =============================================================================
-- SNTC — Migration 0006 — Planification (pg_cron) [OPTIONNEL]
-- =============================================================================
-- Active le balayage automatique des alertes toutes les 15 minutes.
-- Nécessite l'extension pg_cron (activable depuis le dashboard Supabase :
-- Database > Extensions > pg_cron). Sur un projet hébergé, on peut aussi
-- déclencher l'edge function `balayage-alertes` via un cron externe.
-- -----------------------------------------------------------------------------

create extension if not exists pg_cron;

-- Exécute directement la fonction SQL (pas besoin de passer par l'edge function
-- lorsque pg_cron est disponible dans la même base).
select cron.schedule(
  'sntc-balayage-alertes',
  '*/15 * * * *',
  $$ select sntc.balayage_alertes(); $$
);

-- Pour supprimer la planification :
--   select cron.unschedule('sntc-balayage-alertes');
