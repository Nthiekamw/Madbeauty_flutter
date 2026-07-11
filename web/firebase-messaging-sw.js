/* eslint-disable no-undef */
/* Service worker FCM — notifications en arrière-plan (Flutter Web). */
importScripts(
  'https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyCw0rCOMyurSAwIE8ypSbuk-snVTnm8104',
  appId: '1:138830696039:web:b0e7fa2ce9a0075510cec2',
  messagingSenderId: '138830696039',
  projectId: 'fluxetudiant',
  authDomain: 'fluxetudiant.firebaseapp.com',
  storageBucket: 'fluxetudiant.firebasestorage.app',
});

const messaging = firebase.messaging();
const APP_ORIGIN = self.location.origin;
const NOTIFICATION_ICON = `${APP_ORIGIN}/icons/Icon-notification-192.png`;
const NOTIFICATION_BADGE = `${APP_ORIGIN}/icons/Icon-badge-72.png`;

function buildNotificationOptions(payload) {
  const notification = payload.notification || {};
  const data = payload.data || {};
  const type = data.type || 'madbeauty';
  const body = (notification.body || data.body || '').trim();

  return {
    body: body || 'Nouvelle activité sur MadBeauty',
    icon: NOTIFICATION_ICON,
    badge: NOTIFICATION_BADGE,
    tag: `madbeauty-${type}`,
    renotify: true,
    requireInteraction: type === 'booking_created' || type === 'message',
    vibrate: [100, 50, 100],
    data: {
      ...data,
      clickUrl: data.clickUrl || `${APP_ORIGIN}/`,
    },
  };
}

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  const title = (notification.title || 'MadBeauty').trim();
  return self.registration.showNotification(
    title,
    buildNotificationOptions(payload),
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const data = event.notification.data || {};
  const targetUrl = data.clickUrl || `${APP_ORIGIN}/`;
  event.waitUntil(
    clients
      .matchAll({ type: 'window', includeUncontrolled: true })
      .then((windowClients) => {
        for (const client of windowClients) {
          if ('focus' in client) {
            return client.focus();
          }
        }
        if (clients.openWindow) {
          return clients.openWindow(targetUrl);
        }
        return undefined;
      }),
  );
});
