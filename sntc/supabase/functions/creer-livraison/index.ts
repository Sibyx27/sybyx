// =============================================================================
// SNTC — Edge Function : creer-livraison
// =============================================================================
// Crée un bon de livraison et renvoie la charge utile à encoder dans le QR Code.
// Le QR contient { ref, token } : à l'arrivée, le scan + le token signé
// authentifient la livraison (anti-falsification).
//
// Appelé par : Administrateur national ou Gérant (RLS l'exige côté table).
// POST /functions/v1/creer-livraison
// Body: { depot_id, station_id, produit, volume_charge, chauffeur_id?, immatriculation? }
// -----------------------------------------------------------------------------

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    // Client lié à l'utilisateur appelant : le RLS s'applique automatiquement.
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } },
    );

    const body = await req.json();
    const { depot_id, station_id, produit, volume_charge, chauffeur_id, immatriculation } = body;

    if (!depot_id || !station_id || !produit || !volume_charge) {
      return json({ error: "Champs requis manquants" }, 400);
    }
    if (!["essence", "gasoil"].includes(produit)) {
      return json({ error: "Produit invalide" }, 400);
    }
    if (Number(volume_charge) <= 0) {
      return json({ error: "Volume invalide" }, 400);
    }

    const { data: { user } } = await supabase.auth.getUser();

    // La référence et le qr_token sont générés par le trigger en base.
    const { data, error } = await supabase
      .from("livraisons")
      .insert({
        depot_id,
        station_id,
        produit,
        volume_charge,
        chauffeur_id: chauffeur_id ?? null,
        immatriculation: immatriculation ?? null,
        cree_par: user?.id ?? null,
        statut: "creee",
      })
      .select("id, reference, qr_token, produit, volume_charge, station_id, depot_id")
      .single();

    if (error) return json({ error: error.message }, 403);

    // Charge utile compacte pour le QR Code (scannée à l'arrivée).
    const qr_payload = JSON.stringify({ r: data.reference, t: data.qr_token });

    return json({ livraison: data, qr_payload }, 201);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
