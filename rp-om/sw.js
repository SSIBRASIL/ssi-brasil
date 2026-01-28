
const CACHE_NAME = "rp-om-v1";
self.addEventListener("install", e => {
  e.waitUntil(
    caches.open(CACHE_NAME).then(c =>
      c.addAll([
        "./OM_RP_ENGENHARIA_PRODUCAO_FINAL.html",
        "./manifest.json",
        "./RP.jpg"
      ])
    )
  );
});
self.addEventListener("fetch", e => {
  e.respondWith(caches.match(e.request).then(r => r || fetch(e.request)));
});
