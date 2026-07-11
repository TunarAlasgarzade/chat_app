# Chat App

A modern real-time chat application built with Flutter and Firebase.

## Features

### Authentication
- User authentication (login, register, password reset)
- Account deletion with re-authentication

### Messaging
- Real-time messaging with Firebase Firestore
- Message deletion
- Read receipts (sent/read indicators)
- Unread message count badge
- Scroll-to-bottom navigation
- In-app message sound notifications

### Presence & Activity
- Online/offline status indicator
- Real-time typing indicator
- Deleted account indicator in chat

### Contacts
- Add, delete, and rename contacts
- Block and unblock contacts
- Blocked users management (Settings > Blocked Users)

### Notifications
- Push notifications via OneSignal
- Automatic OneSignal ID synchronization
- Notifications suppressed when the app is open
- Notifications suppressed when the user is blocked
- Cloudflare Worker used as a secure notification backend

### Customization
- Dark/Light mode toggle
- Accent color selection (7 colors)
- Appearance settings
- Bottom navigation (Chats, Profile, Settings)

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- OneSignal
- Cloudflare Workers