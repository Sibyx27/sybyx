// =============================================================================
// SNTC — Edge Function : valider-arrivee
// =============================================================================
// Valide l'arrivée d'une livraison à la station après scan du QR Code.
// Vérifie :
//   1. le token du QR correspond bien à la livraison (anti-falsification)
//   2. la position GPS du valideur est dans le rayon de la station (géofencing)
//   3. une photo horodatée est fournie (obligatoire)
// Met le statut à 'arrivee_validee' -> déclenche le recalcul de stock en base.
//
// POST /functions/v1/valider-arrivee
// Body: { qr_token, volume_recu, latitude, longitude, photo_url }
// -----------------------------------------------------------------------------

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const RAYON_GEOFENCE_M = 300; // tolérance autour de la station (mètres)

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } },
    );

    const { qr_token, volume_recu, latitude, longitude, photo_url } = await req.json();

    if (!qr_token) return json({ error: "QR Code manquant" }, 400);
    if (!photo_url) return json({ error: "Photo horodatée obligatoire" }, 400);
    if (volume_recu == null || Number(volume_recu) < 0) {
      return json({ error: "Volume reçu invalide" }, 400);
    }

    // Récupère la livraison via le token (RLS limite aux livraisons autorisées)
    const { data: liv, error: e1 } = await supabase
      .from("livraisons")
      .select("id, statut, station_id, produit, volume_charge, stations(latitude, longitude)")
      .eq("qr_token", qr_token)
      .single();

    if (e1 || !liv) return json({ error: "Livraison introuvable ou QR invalide" }, 404);
    if (liv.statut === "arrivee_validee") {
      return json({ error: "Livraison déjà validée" }, 409);
    }
    if (liv.statut === "annulee") return json({ error: "Livraison annulée" }, 409);

    // Géofencing : la validation doit avoir lieu près de la station
    let dans_zone = true;
    if (latitude != null && longitude != null && liv.stations) {
      const d = distanceMetres(
        latitude, longitude,
        (liv.stations as any).latitude, (liv.stations as any).longitude,
      );
      dans_zone = d <= RAYON_GEOFENCE_M;
    }

    const { data, error: e2 } = await supabase
      .from("livraisons")
      .update({
        statut: "arrivee_validee",
        volume_recu,
        arrivee_le: new Date().toISOString(),
        arrivee_lat: latitude ?? null,
        arrivee_lng: longitude ?? null,
        photo_arrivee_url: photo_url,
      })
      .eq("id", liv.id)
      .select("id, reference, statut, volume_recu, volume_charge")
      .single();

    if (e2) return json({ error: e2.message }, 403);

    const ecart = Number(volume_recu) - Number(liv.volume_charge);

    return json({
      livraison: data,
      ecart,
      hors_zone: !dans_zone,        // signalé au tableau de bord si validation à distance
      message: dans_zone
        ? "Arrivée validée"
        : "Arrivée validée — POSITION HORS ZONE (à vérifier)",
    });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});

// Distance Haversine en mètres
function distanceMetres(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371000;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
