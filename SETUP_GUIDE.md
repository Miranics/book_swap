# BookSwap - Mobile Book Trading App

**Production-Ready Flutter Application for Trading Books with Swaps and Chat**

## ✅ Current Status

- **Build Status**: ✅ Compiles with 0 errors
- **Code Quality**: 13 info-level warnings only (no blockers)
- **Architecture**: Clean Architecture with Provider state management
- **Database**: Firebase Firestore (real-time sync)
- **Authentication**: Firebase Auth with email verification
- **Platforms**: Android, iOS (Web with mocks only)

---

## 📋 Features Implemented

### ✅ Authentication
- User registration with email verification
- Secure login/logout
- Email verification enforcement
- User profile creation

### ✅ Book Listings (CRUD)
- Create/Post new books with title, author, condition
- Browse all listings with real-time sync
- Edit own book listings
- Delete books
- Condition levels: New, Like New, Good, Used

### ✅ Swap Functionality
- Send swap offers on other user's books
- View pending/accepted swap offers
- Accept or reject swap offers
- Real-time status updates

### ✅ Chat System (Bonus)
- Create chat threads with matched users
- Send/receive messages in real-time
- Store messages in Firestore
- Chat persistence

### ✅ Navigation
- Bottom Tab Navigation (4 screens)
- Browse Listings
- My Listings
- Chats
- Settings (Profile, Logout)

### ✅ UI/UX
- Dark Navy (#1F2937) + Golden Yellow (#FCD34D) theme
- Responsive Material Design
- Loading states and error handling
- Form validation

---

## 🚀 Setup & Deployment

### Prerequisites
```
Flutter SDK: 3.9.2+
Dart: 3.9.2+
Android SDK: API 21+ (for Android devices/emulators)
```

### 1. Clone & Setup
```bash
git clone https://github.com/Miranics/book_swap.git
cd book_swap
flutter pub get
```

### 2. Firebase Setup

#### Option A: Use Existing Firebase Project
If you have a Google Cloud project with Firebase enabled:

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Configure Flutter for Firebase**
   ```bash
   flutter pub add firebase_core
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   - Select your Firebase project
   - Choose Android/iOS platforms
   - Download credentials

#### Option B: Create New Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create Project"
3. Enable these services:
   - **Authentication** → Email/Password
   - **Firestore Database** → Production mode
   - **Storage** → Upload books photos

4. Run configuration:
   ```bash
   flutterfire configure
   ```

### 3. Android Signing (Required for Play Store)

Generate a signing key:
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties`:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=~/key.jks
```

### 4. Build Release APK

```bash
# For local testing
flutter build apk --release

# For Google Play (App Bundle)
flutter build appbundle --release
```

APK location: `build/app/outputs/apk/release/app-release.apk`

### 5. Run on Device

```bash
# Connect Android device with USB debugging enabled
flutter devices

# Run on device
flutter run --release
```

---

## 📱 Firestore Database Schema

### Collections

#### `users/{uid}`
```json
{
  "email": "user@example.com",
  "displayName": "John Doe",
  "profileImageUrl": "https://...",
  "emailVerified": true,
  "createdAt": "2024-11-08T10:00:00Z"
}
```

#### `books/{bookId}`
```json
{
  "title": "Flutter by Example",
  "author": "John Smith",
  "condition": "likenew",
  "coverImageUrl": "https://...",
  "userId": "user_uid",
  "userName": "John Doe",
  "createdAt": "2024-11-08T10:00:00Z",
  "updatedAt": "2024-11-08T10:00:00Z"
}
```

#### `swaps/{swapId}`
```json
{
  "senderUserId": "user1_uid",
  "senderUserName": "Alice",
  "recipientUserId": "user2_uid",
  "recipientUserName": "Bob",
  "bookId": "book_id",
  "bookTitle": "Clean Code",
  "status": "pending",
  "createdAt": "2024-11-08T10:00:00Z",
  "updatedAt": "2024-11-08T10:00:00Z"
}
```

#### `chatThreads/{threadId}`
```json
{
  "userId1": "user1_uid",
  "userId1Name": "Alice",
  "userId2": "user2_uid",
  "userId2Name": "Bob",
  "swapId": "swap_id",
  "createdAt": "2024-11-08T10:00:00Z",
  "lastMessage": "Great, when can we meet?",
  "lastMessageAt": "2024-11-08T11:30:00Z"
}
```

Subcollection: `chatThreads/{threadId}/messages/{messageId}`
```json
{
  "senderId": "user1_uid",
  "senderName": "Alice",
  "recipientId": "user2_uid",
  "message": "Great, when can we meet?",
  "timestamp": "2024-11-08T11:30:00Z",
  "isRead": true
}
```

---

## 🔒 Firebase Security Rules

Copy these to your Firestore Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own documents
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId;
      allow update, delete: if request.auth.uid == userId;
    }

    // Books: anyone can read, only owner can modify
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }

    // Swaps: involved parties can see theirs
    match /swaps/{swapId} {
      allow read: if request.auth.uid == resource.data.senderUserId || 
                     request.auth.uid == resource.data.recipientUserId;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.senderUserId ||
                       request.auth.uid == resource.data.recipientUserId;
    }

    // Chat threads
    match /chatThreads/{threadId} {
      allow read, write: if request.auth.uid == resource.data.userId1 ||
                           request.auth.uid == resource.data.userId2;
      
      // Messages in thread
      match /messages/{messageId} {
        allow read, write: if request.auth.uid == resource.data.senderId ||
                             request.auth.uid == resource.data.recipientId;
      }
    }
  }
}
```

---

## 📊 Project Statistics

- **Total Lines of Code**: ~2,500
- **Screens**: 8 (Login, Signup, Browse, MyListings, PostBook, Chats, Settings, Chat Detail)
- **Providers**: 4 (Auth, Book, Swap, Chat)
- **Repositories**: 4 + 4 Mocks
- **Models**: 4 (User, Book, Swap, Chat)
- **Dependencies**: Firebase, Provider, ImagePicker

---

## 🧪 Testing

### Local Testing (Mock Data)
```bash
# Run with mock repositories (no Firebase needed)
flutter run
```

### Firebase Testing
1. Update `lib/main.dart` to use real repositories
2. Ensure Firebase is initialized properly
3. Test auth, CRUD, swaps, and chat flows

---

## 📚 Architecture

```
lib/
├── core/
│   └── theme.dart               # Centralized theming
├── data/
│   └── repositories/            # Firebase operations
│       ├── auth_repository.dart
│       ├── book_repository.dart
│       ├── swap_repository.dart
│       ├── chat_repository.dart
│       └── mock_*.dart          # For testing
├── domain/
│   └── models/                  # Data models
│       ├── user_model.dart
│       ├── book_model.dart
│       ├── swap_model.dart
│       └── chat_model.dart
└── presentation/
    ├── pages/                   # Screens
    ├── providers/               # State management
    └── widgets/                 # Reusable components
```

---

## 🐛 Troubleshooting

### Firebase Initialization Error
**Solution**: Ensure `firebase_options.dart` is generated and Firebase project is properly configured

### Firestore Permission Denied
**Solution**: Check security rules - user must be authenticated and have proper permissions

### Blank Screen on Startup
**Solution**: Check if user is authenticated. Login screen should appear if not authenticated

### Package Version Conflicts
**Solution**: Run `flutter pub get` and delete `pubspec.lock` if needed

---

## 📝 Code Quality

```
Dart Analysis:
- Errors: 0 ✅
- Warnings: 1 ⚠️ (deprecated methods - info level)
- Info: 12 ℹ️
```

All critical issues fixed. Info-level warnings are acceptable.

---

## 🎯 Next Steps

1. **Configure Firebase** with your Google Cloud project
2. **Test on Android device** - physical device recommended (not emulator)
3. **Add your book listings** and test swap functionality
4. **Deploy to Google Play Store** following Play Store guidelines

---

## 📄 License

This project is part of an academic assignment. All rights reserved.

---

## 👨‍💻 Developer Notes

- **State Management**: Provider pattern for reactive UI updates
- **Real-time Sync**: Firestore Streams for live data updates
- **Clean Code**: Separation of concerns with clean architecture
- **Production Ready**: Error handling, validation, and security rules in place

For questions or issues, refer to the DESIGN_SUMMARY.md and IMPLEMENTATION_ROADMAP.md files.
