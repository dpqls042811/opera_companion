const STATIC_CACHE = 'static-v2';
const DYNAMIC_CACHE = 'dynamic-v2';

const APP_SHELL = [
  '/',
  '/index.html',
  '/manifest.json',
  '/flutter.js',
  '/flutter_bootstrap.js',
  '/main.dart.js',
  '/version.json',
  '/assets/FontManifest.json',
  '/assets/fonts/MaterialIcons-Regular.otf',
  '/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/favicon.png',
];

self.addEventListener('install', (event) => {
  console.log('[SW] install');

  event.waitUntil((async () => {
    const cache = await caches.open(STATIC_CACHE);
    await cache.addAll(APP_SHELL);
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  console.log('[SW] activate');

  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(
      keys.map((key) => {
        if (key !== STATIC_CACHE && key !== DYNAMIC_CACHE) {
          return caches.delete(key);
        }
        return Promise.resolve();
      })
    );
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const req = event.request;

  if (req.method !== 'GET') return;

  const url = new URL(req.url);

  if (url.origin !== self.location.origin) return;

  if (req.mode === 'navigate') {
    event.respondWith((async () => {
      const cached = await caches.match('/index.html');
      if (cached) return cached;

      try {
        return await fetch(req);
      } catch (e) {
        return cached;
      }
    })());
    return;
  }

  const path = url.pathname;

  const isCoreAsset =
    APP_SHELL.includes(path) ||
    path.endsWith('.js') ||
    path.endsWith('.css');

  if (isCoreAsset) {
    event.respondWith((async () => {
      const cached = await caches.match(req);
      if (cached) return cached;

      try {
        const network = await fetch(req);
        if (network && network.ok) {
          const cache = await caches.open(STATIC_CACHE);
          await cache.put(req, network.clone());
        }
        return network;
      } catch (e) {
        return cached;
      }
    })());
    return;
  }

  event.respondWith((async () => {
    const cached = await caches.match(req);
    if (cached) {
      return cached;
    }

    try {
      const network = await fetch(req);
      if (network && network.ok) {
        const cache = await caches.open(DYNAMIC_CACHE);
        await cache.put(req, network.clone());
      }
      return network;
    } catch (e) {
      return cached;
    }
  })());
});
