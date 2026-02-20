importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyB0hISNv8DVu3rO0U-SzMp37RtZxyTJySE',
  appId: '1:91333191859:web:1b192e74a0aa2b6017a8c6',
  messagingSenderId: '91333191859',
  projectId: 'sugarless-252ae',
  authDomain: 'sugarless-252ae.firebaseapp.com',
  storageBucket: 'sugarless-252ae.firebasestorage.app',
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);

  const notificationTitle = payload.notification?.title || 'New Message';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});