let cacheData = "appV1";

this.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(cacheData).then((cache) => {
      return cache.addAll([
        "/index.html",
        "/",
        "/favicon.ico",
        "/logo192.png",
        "/logo512.png",
        "/manifest.json",
        "/static/css/main.234742d6.css",
        "/static/js/main.3614101f.js",
      ]);
    })
  );
});

this.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      // If the cache has the requested resource, return it
      if (cachedResponse) {
        return cachedResponse;
      }

      // If the request is a navigation request (e.g., /login), serve index.html from cache
      if (event.request.mode === "navigate") {
        return caches.match("/index.html");
      }

      // Otherwise, fetch it from the network
      return fetch(event.request).catch(() => {
        // If fetch fails (e.g., offline) and it's not a navigation request, return nothing
        return new Response("No network connection", {
          status: 503,
          statusText: "No network connection",
        });
      });
    })
  );
});
