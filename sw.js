/* Service Worker for QR Actions - Enhanced with Update Detection */
const CACHE_NAME = 'qr-actions-v102'; // CHANGE THIS VERSION WHEN YOU UPDATE!
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  'https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js',
  'https://cdn.jsdelivr.net/npm/qrcode-generator@1.4.4/qrcode.min.js'
];

// Install event: cache all essential assets
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installing new version:', CACHE_NAME);
  
  // Force the waiting service worker to become active
  self.skipWaiting();
  
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[Service Worker] Caching assets');
      return cache.addAll(ASSETS).catch(error => {
        console.error('[Service Worker] Cache addAll failed:', error);
        // Still resolve so installation continues
      });
    })
  );
});

// Activate event: cleanup old caches
self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activating new version:', CACHE_NAME);
  
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map(key => {
          if (key !== CACHE_NAME) {
            console.log('[Service Worker] Deleting old cache:', key);
            return caches.delete(key);
          }
        })
      );
    }).then(() => {
      console.log('[Service Worker] Now controlling all clients');
      // Take control of all clients immediately
      return self.clients.claim();
    })
  );
});

// Fetch event: network first, then cache (for dynamic updates)
self.addEventListener('fetch', (event) => {
  // Skip cross-origin requests like CDN fonts
  if (!event.request.url.startsWith(self.location.origin) && 
      !event.request.url.includes('unpkg.com') && 
      !event.request.url.includes('cdn.jsdelivr.net')) {
    return;
  }

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Cache successful responses for offline
        if (response.status === 200) {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseClone);
          });
        }
        return response;
      })
      .catch(() => {
        // Fallback to cache when offline
        return caches.match(event.request);
      })
  );
});

// Listen for messages from the web app
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    console.log('[Service Worker] Skip waiting requested');
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage(CACHE_NAME);
  }
});

// Background sync for offline actions (optional)
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-scans') {
    console.log('[Service Worker] Background sync triggered');
    // You could implement offline queue here
  }
});
