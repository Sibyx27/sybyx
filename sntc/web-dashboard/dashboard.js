// =============================================================================
// SNTC — Tableau de bord gouvernemental (Web)
// =============================================================================
// SPA légère : authentification Supabase, carte nationale Mapbox, KPIs en
// temps réel. Réservé aux rôles admin_national / controleur (le RLS borne
// de toute façon les données accessibles).
// -----------------------------------------------------------------------------

const cfg = window.SNTC_CONFIG;
const sb = supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY, {
  db: { schema: "sntc" },
});

const ETAT_COULEUR = { normal: "#1E9E5A", faible: "#E8B500", rupture: "#D33A2C", inactive: "#2B2B2B" };

let map = null;
let realtimeChannel = null;

// --- Authentification -------------------------------------------------------
const $ = (id) => document.getElementById(id);

$("btn-login").addEventListener("click", async () => {
  $("login-error").textContent = "";
  const { error } = await sb.auth.signInWithPassword({
    email: $("email").value.trim().toLowerCase(),
    password: $("password").value,
  });
  if (error) $("login-error").textContent = error.message;
});

$("btn-logout").addEventListener("click", () => sb.auth.signOut());

sb.auth.onAuthStateChange(async (_e, session) => {
  if (session) await demarrer(session);
  else afficherLogin();
});

(async () => {
  const { data } = await sb.auth.getSession();
  if (data.session) await demarrer(data.session);
})();

function afficherLogin() {
  $("login").classList.remove("hidden");
  $("app").classList.add("hidden");
  if (realtimeChannel) sb.removeChannel(realtimeChannel);
}

// --- Démarrage de l'application ---------------------------------------------
async function demarrer(session) {
  // Vérifie le rôle (lecture nationale réservée admin/contrôleur)
  const { data: profile } = await sb
    .from("profiles").select("role, nom_complet").eq("id", session.user.id).single();

  if (!profile || !["admin_national", "controleur"].includes(profile.role)) {
    $("login-error").textContent = "Accès réservé aux administrateurs et contrôleurs.";
    await sb.auth.signOut();
    return;
  }

  $("login").classList.add("hidden");
  $("app").classList.remove("hidden");
  $("user-label").textContent = `${profile.nom_complet} · ${profile.role}`;

  initMap();
  await rafraichir();
  abonnerTempsReel();
}

// --- Carte Mapbox -----------------------------------------------------------
function initMap() {
  if (map) return;
  mapboxgl.accessToken = cfg.MAPBOX_TOKEN;
  map = new mapboxgl.Map({
    container: "map",
    style: "mapbox://styles/mapbox/light-v11",
    center: [-7.99, 12.63], // Bamako
    zoom: 11,
  });
  map.addControl(new mapboxgl.NavigationControl(), "top-right");
}

let markers = [];
function dessinerStations(stations) {
  markers.forEach((m) => m.remove());
  markers = [];
  for (const s of stations) {
    if (s.latitude == null || s.longitude == null) continue;
    const el = document.createElement("div");
    el.className = "marker";
    el.style.background = ETAT_COULEUR[s.etat] ?? "#888";

    const popup = new mapboxgl.Popup({ offset: 14 }).setHTML(`
      <strong>${s.nom}</strong><br>
      <small>${s.code} · ${s.region ?? ""}</small><br>
      Essence : <b>${Math.round(s.stock_essence)} L</b><br>
      Gasoil : <b>${Math.round(s.stock_gasoil)} L</b><br>
      ${s.alertes_ouvertes > 0 ? `<span style="color:#D33A2C">⚠ ${s.alertes_ouvertes} alerte(s)</span>` : "✓ RAS"}
    `);
    const m = new mapboxgl.Marker(el).setLngLat([s.longitude, s.latitude]).setPopup(popup).addTo(map);
    markers.push(m);
  }
}

// --- Données ----------------------------------------------------------------
async function rafraichir() {
  const [kpi, stations, regions, alertes, suspectes] = await Promise.all([
    sb.from("v_dashboard_national").select("*").single(),
    sb.from("v_carte_stations").select("*"),
    sb.from("v_stock_par_region").select("*"),
    sb.from("alertes").select("*, stations(nom)").eq("resolue", false).eq("severite", "critique").order("created_at", { ascending: false }).limit(20),
    sb.from("v_stations_suspectes").select("*").limit(15),
  ]);

  rendreKpis(kpi.data);
  if (stations.data) dessinerStations(stations.data);
  rendreRegions(regions.data ?? []);
  rendreAlertes(alertes.data ?? []);
  rendreSuspectes(suspectes.data ?? []);
}

function fmt(n) { return n != null ? Math.round(n).toLocaleString("fr-FR") : "—"; }

function rendreKpis(k) {
  if (!k) return;
  const items = [
    ["Stock essence", fmt(k.stock_national_essence) + " L", "#0E2240"],
    ["Stock gasoil", fmt(k.stock_national_gasoil) + " L", "#0E2240"],
    ["Stations", fmt(k.nb_stations), "#0E2240"],
    ["Livraisons du jour", fmt(k.livraisons_jour), "#1E9E5A"],
    ["En rupture", fmt(k.stations_rupture), "#D33A2C"],
    ["Suspectes", fmt(k.stations_suspectes), "#E8B500"],
    ["Alertes critiques", fmt(k.alertes_critiques), "#D33A2C"],
  ];
  $("kpis").innerHTML = items.map(([l, v, c]) =>
    `<div class="kpi"><span class="kpi-val" style="color:${c}">${v}</span><span class="kpi-lbl">${l}</span></div>`,
  ).join("");
}

function rendreRegions(rows) {
  $("regions-table").querySelector("tbody").innerHTML = rows.map((r) =>
    `<tr><td>${r.region}</td><td>${fmt(r.nb_stations)}</td><td>${fmt(r.stock_essence)}</td><td>${fmt(r.stock_gasoil)}</td><td>${fmt(r.stations_rupture)}</td></tr>`,
  ).join("");
}

function rendreAlertes(rows) {
  $("alertes").innerHTML = rows.length
    ? rows.map((a) => `<li class="alerte"><b>${a.stations?.nom ?? ""}</b> — ${a.message}</li>`).join("")
    : "<li class='empty'>Aucune alerte critique.</li>";
}

function rendreSuspectes(rows) {
  $("suspectes").innerHTML = rows.length
    ? rows.map((s) => `<li class="suspect"><b>${s.nom}</b> (${s.region}) — ${s.nb_infractions} infraction(s), ${s.nb_ecarts} écart(s)</li>`).join("")
    : "<li class='empty'>Aucune station suspecte.</li>";
}

// --- Temps réel (Supabase Realtime) -----------------------------------------
function abonnerTempsReel() {
  realtimeChannel = sb
    .channel("sntc-dashboard")
    .on("postgres_changes", { event: "*", schema: "sntc", table: "alertes" }, rafraichir)
    .on("postgres_changes", { event: "*", schema: "sntc", table: "stations" }, rafraichir)
    .subscribe();

  // Filet de sécurité : rafraîchissement périodique
  setInterval(rafraichir, 60_000);
}
