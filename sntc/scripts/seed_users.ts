// =============================================================================
// SNTC — Provisionnement des comptes de démonstration (Supabase Admin API)
// =============================================================================
// Crée les utilisateurs auth avec leur rôle dans app_metadata (utilisé par le
// JWT et le RLS). Les UUID sont fixés pour correspondre au seed SQL.
//
// Usage :
//   export SUPABASE_URL="https://xxxx.supabase.co"
//   export SUPABASE_SERVICE_ROLE_KEY="..."   (NE JAMAIS committer)
//   deno run --allow-env --allow-net scripts/seed_users.ts
//
// Mots de passe de démo (à changer impérativement avant tout pilote réel).
// -----------------------------------------------------------------------------

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { autoRefreshToken: false, persistSession: false } },
);

type DemoUser = {
  id: string;
  email: string;
  password: string;
  role: string;
  nom_complet: string;
  telephone: string;
  station_id?: string;
};

const users: DemoUser[] = [
  { id: "33333333-0000-0000-0000-000000000001", email: "admin@sntc.ml",      password: "Sntc!Demo2026", role: "admin_national", nom_complet: "Aminata Traoré",   telephone: "+22370000001" },
  { id: "33333333-0000-0000-0000-000000000002", email: "controleur@sntc.ml", password: "Sntc!Demo2026", role: "controleur",     nom_complet: "Modibo Keïta",      telephone: "+22370000002" },
  { id: "33333333-0000-0000-0000-000000000003", email: "gerant.aci@sntc.ml", password: "Sntc!Demo2026", role: "gerant",         nom_complet: "Fatoumata Diarra",  telephone: "+22370000003", station_id: "22222222-0000-0000-0000-000000000001" },
  { id: "33333333-0000-0000-0000-000000000004", email: "gerant.mag@sntc.ml", password: "Sntc!Demo2026", role: "gerant",         nom_complet: "Ousmane Coulibaly", telephone: "+22370000004", station_id: "22222222-0000-0000-0000-000000000004" },
  { id: "33333333-0000-0000-0000-000000000005", email: "chauffeur@sntc.ml",  password: "Sntc!Demo2026", role: "chauffeur",      nom_complet: "Ibrahim Sangaré",   telephone: "+22370000005", station_id: "22222222-0000-0000-0000-000000000001" },
];

for (const u of users) {
  const { error } = await supabase.auth.admin.createUser({
    user_id: u.id,
    email: u.email,
    password: u.password,
    email_confirm: true,
    app_metadata: { role: u.role, station_id: u.station_id ?? null },
    user_metadata: { nom_complet: u.nom_complet, telephone: u.telephone },
  });

  if (error && !String(error.message).includes("already")) {
    console.error(`✗ ${u.email}:`, error.message);
  } else {
    console.log(`✓ ${u.email} (${u.role})`);
  }
}

console.log("\nComptes de démonstration prêts. Mot de passe : Sntc!Demo2026");
console.log("⚠  Changez tous les mots de passe avant un déploiement réel.");
