// Balila Barber Street — mode hors-ligne.
// Avec internet : on prend toujours la dernière version (et on la garde en réserve).
// Sans internet : on sert la copie gardée sur l'appareil.
const RESERVE = "bbs-v10";
const FICHIERS = ["./", "./index.html", "./manifest.webmanifest", "./icone.svg", "./icone-192.png", "./icone-512.png",
  "./polices/figtree-latin-wght-normal.woff2", "./polices/figtree-latin-ext-wght-normal.woff2",
  "./polices/bricolage-grotesque-latin-wght-normal.woff2", "./polices/bricolage-grotesque-latin-ext-wght-normal.woff2"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(RESERVE).then(c => c.addAll(FICHIERS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(caches.keys()
    .then(cles => Promise.all(cles.filter(k => k !== RESERVE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});

self.addEventListener("fetch", e => {
  const r = e.request;
  if (r.method !== "GET") return;
  e.respondWith(
    fetch(r).then(rep => {
      if (rep && (rep.ok || rep.type === "opaque")) {
        const copie = rep.clone();
        caches.open(RESERVE).then(c => c.put(r, copie));
      }
      return rep;
    }).catch(() =>
      caches.match(r, { ignoreSearch: true }).then(m =>
        m || (r.mode === "navigate" ? caches.match("./index.html") : Response.error())))
  );
});
