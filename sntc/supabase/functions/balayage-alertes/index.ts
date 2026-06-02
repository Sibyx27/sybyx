// =============================================================================
// SNTC — Edge Function : balayage-alertes  (tâche planifiée)
// =============================================================================
// Déclenchée toutes les 15 min par pg_cron (ou un cron externe). Appelle la
// fonction SQL sntc.balayage_alertes() qui :
//   - détecte les livraisons non validées (>12h)
//   - réévalue l'état (couleur) de toutes les stations
//   - lève les alertes rupture / sans-vente-24h / rupture imminente
//
// Protégée par un secret partagé (header x-cron-secret) plutôt qu'un JWT,
// car appelée par une machine, pas un utilisateur.
// -----------------------------------------------------------------------------

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  // Authentification machine-à-machine par secret partagé
  const secret = req.headers.get("x-cron-secret");
  if (secret !== Deno.env.get("CRON_SECRET")) {
    return new Response("Forbidden", { status: 403 });
  }

  // service_role : contourne le RLS pour le balayage système
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data, error } = await supabase.rpc("balayage_alertes");

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(
    JSON.stringify({ ok: true, livraisons_non_validees: data, ts: new Date().toISOString() }),
    { headers: { "Content-Type": "application/json" } },
  );
});
