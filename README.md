# BookSwap - Flutter Mobile App

A marketplace application where students can list textbooks they wish to exchange and initiate swap offers with other users. Built with Flutter, Firebase, and Provider state management.

## Project Overview

BookSwap enables students to:
- **Authenticate** with email/password and email verification
- **Post books** with title, author, condition, and cover image
- **Browse** listings from other students
- **Initiate swaps** and track swap status
- **Chat** with other users after swap initiation
- **Manage profile** and notification preferences

## Architecture

### Clean Architecture Pattern

The project follows clean architecture with clear separation of concerns:

```
lib/
├── core/                          # Core configurations
│   └── theme.dart                # App theming (Dark Navy + Golden Yellow)
├── data/                          # Data layer
│   ├── models/                   # Firestore models
│   └── repositories/             # Repository implementations
├── domain/                        # Domain layer
│   └── models/                   # Business models
├── presentation/                  # Presentation layer
│   ├── pages/                    # Screen widgets
│   │   ├── auth/                 # Authentication screens
│   │   └── *.dart                # Feature screens
│   ├── providers/                # State management (Provider)
│   └── widgets/                  # Reusable widgets
└── main.dart                      # App entry point
```

### State Management: Provider

The app uses **Provider** for reactive state management:

- **AuthProvider**: Manages authentication state and user profile
- **BookProvider**: Handles CRUD operations for book listings
- **SwapProvider**: Manages swap offers and state transitions  
- **ChatProvider**: Handles real-time chat functionality

#### State Management Flow:
```
UI Layer (Widgets)
    ↓ listens to
Provider (ChangeNotifier)
    ↓ calls methods on
Repository
    ↓ performs operations on
Firebase (Firestore + Auth)
    ↓ streams data back to
Provider → UI
```

## Features Implemented

### 1. Authentication (✅ Complete)
- Email/Password signup with Firebase Auth
- Email verification enforcement - users cannot login until verified
- Login with email verification check
- Logout functionality
- User profile creation

### 2. Book Listings CRUD (✅ Complete)
- **Create**: Post books with title, author, condition
- **Read**: Browse all listings in shared feed
- **Update**: Edit your own book listings
- **Delete**: Remove book listings

### 3. Navigation (✅ Complete)
**BottomNavigationBar** with 4 main screens:
1. Browse - View all listings
2. My Listings - Your posted books
3. Chats - Messaging (Bonus)
4. Settings - Profile & preferences

### 4. Settings Screen (✅ Complete)
- Display user profile information
- Email verification status
- Notification preference toggles
- Logout functionality

### 5. Swap Functionality (🔄 In Progress)
- Initiate swap offers
- Track pending/accepted/rejected states
- Real-time sync via Firestore

### 6. Chat System (🔄 Bonus)
- Create chat threads between users
- Real-time messaging
- Firestore persistence

## Database Schema (Firestore)

### Collections Structure

**users/** - User profiles
**books/** - Book listings  
**swaps/** - Swap transactions
**chatThreads/** - Chat conversations with messages subcollection

## Setup Instructions

### Prerequisites
- Flutter 3.0+
- Dart SDK
- Firebase project
- Android/iOS dev environment

### Installation

```bash
# Clone repository
git clone https://github.com/Miranics/book_swap.git
cd book_swap

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Key Dependencies

```yaml
firebase_core: ^2.32.0
firebase_auth: ^4.16.0
cloud_firestore: ^4.17.5
provider: ^6.0.0
image_picker: ^1.0.4
firebase_storage: ^11.6.5
```

## Project Status

✅ Clean Architecture Setup  
✅ State Management (Provider)  
✅ Authentication  
✅ Navigation  
⚙️ CRUD Operations  
⚙️ Swap Functionality  
⚙️ Chat System

## Getting Started

More info on Flutter:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
