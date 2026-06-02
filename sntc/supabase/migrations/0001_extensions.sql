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
