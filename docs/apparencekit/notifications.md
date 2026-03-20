# ApparenceKit Notifications

> Source: https://apparencekit.dev/docs/start/overview/

## Architecture

Push notifications use **Firebase Cloud Messaging (FCM)** because Supabase does not provide a push notification service. This is required for iOS push notifications in Flutter.

### Components

- **Firebase Cloud Messaging** — Delivers push notifications to iOS and Android
- **Device API** (`lib/modules/notifications/api/device_api.dart`) — Registers devices, manages FCM tokens
- **Notification API** (`lib/modules/notifications/api/notification_api.dart`) — Fetches notification history
- **Local Notifier** (`lib/modules/notifications/api/local_notifier.dart`) — Shows local notifications

## Setup

1. Firebase project must be configured (see supabase-setup.md, section 5)
2. FCM must be enabled in the Firebase console
3. For iOS: APNs key must be uploaded to Firebase

## How It Works

1. On app start, the device registers with FCM and gets a token
2. The token is stored in the backend (Firestore `users/{userId}/devices` collection)
3. When a notification needs to be sent, the backend looks up the device token and sends via FCM
4. The app receives the notification via `FirebaseMessaging.onMessage` (foreground) or `onBackgroundMessage` (background)

## Device Registration

The `DeviceApi` class handles:
- Getting the FCM token from `FirebaseMessaging`
- Getting the installation ID from `FirebaseInstallations`
- Registering/updating/unregistering devices in the backend
- Listening for token refreshes

## Local Notifications

Local notifications are shown via `flutter_local_notifications` when a push notification arrives while the app is in the foreground.

## Notification Permissions

The app requests notification permissions on first launch. On iOS 16+, this uses the provisional authorization flow. On Android 13+, the `POST_NOTIFICATIONS` permission is requested.
