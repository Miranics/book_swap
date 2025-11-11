# BookSwap Backend Implementation Guide

## 🏗️ Architecture Overview

The BookSwap app uses a **Clean Architecture** pattern with the following layers:

```
┌─────────────────────────────────────────────────────────┐
│            Presentation Layer (UI)                       │
│  Pages → Providers → Widgets                             │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│            Domain Layer (Models)                         │
│  UserModel → BookModel → SwapModel → ChatModel          │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│            Data Layer (Repositories)                     │
│  AuthRepository → BookRepository → SwapRepository        │
│  → ChatRepository                                        │
└──────────────────────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│            External Services (Firebase)                  │
│  Authentication → Firestore → Storage                   │
└──────────────────────────────────────────────────────────┘
```

---

## 📦 Data Models

### 1. **UserModel** (`lib/domain/models/user_model.dart`)
```dart
class UserModel {
  String id                    // Firebase UID
  String email                 // User's email
  String? displayName         // User's name
  String? profileImageUrl     // Avatar URL
  bool emailVerified          // Email verification status
  DateTime createdAt          // Account creation time
}
```

**Firestore Collection: `users/{userId}`**
```json
{
  "id": "user123",
  "email": "john@example.com",
  "displayName": "John Doe",
  "profileImageUrl": "https://...",
  "emailVerified": true,
  "createdAt": "2025-11-08T10:00:00Z"
}
```

### 2. **BookModel** (`lib/domain/models/book_model.dart`)
```dart
class BookModel {
  String id                    // Document ID
  String title                 // Book title
  String author                // Author name
  BookCondition condition      // new_ / likeNew / good / used
  String? coverImageUrl        // Firebase Storage URL
  String userId                // Owner's ID
  String userName              // Owner's display name
  DateTime createdAt           // Posted date
}

enum BookCondition { new_, likeNew, good, used }
```

**Firestore Collection: `books/{bookId}`**
```json
{
  "id": "book123",
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "condition": "likeNew",
  "coverImageUrl": "gs://bucket/books/cover123.jpg",
  "userId": "user123",
  "userName": "John Doe",
  "createdAt": "2025-11-08T10:00:00Z"
}
```

### 3. **SwapModel** (`lib/domain/models/swap_model.dart`)
```dart
class SwapModel {
  String id                    // Document ID
  String bookId                // Book being offered
  String senderUserId          // Person making offer
  String senderUserName        // Sender's name
  String recipientUserId       // Book owner
  String recipientUserName     // Recipient's name
  SwapStatus status            // pending / accepted / rejected / completed
  DateTime createdAt           // Offer creation time
}

enum SwapStatus { pending, accepted, rejected, completed }
```

**Firestore Collection: `swaps/{swapId}`**
```json
{
  "id": "swap123",
  "bookId": "book123",
  "senderUserId": "user456",
  "senderUserName": "Alice",
  "recipientUserId": "user123",
  "recipientUserName": "John Doe",
  "status": "pending",
  "createdAt": "2025-11-08T11:00:00Z"
}
```

### 4. **ChatModel** (`lib/domain/models/chat_model.dart`)

**ChatMessage:**
```dart
class ChatMessage {
  String id                    // Document ID
  String senderId              // Sender's ID
  String senderName            // Sender's display name
  String recipientId           // Recipient's ID
  String message               // Message content
  DateTime timestamp           // Send time
  bool isRead                  // Read status
}
```

**ChatThread:**
```dart
class ChatThread {
  String id                    // Document ID
  String userId1               // First participant
  String userId1Name           // First participant name
  String userId2               // Second participant
  String userId2Name           // Second participant name
  String? swapId              // Associated swap (optional)
  DateTime createdAt           // Thread creation
  DateTime? lastMessageAt      // Last message timestamp
  String? lastMessage          // Last message preview
}
```

**Firestore Structure:**
```
chatThreads/
  {threadId}/
    metadata:
      userId1, userId1Name
      userId2, userId2Name
      swapId, createdAt
      lastMessageAt, lastMessage
    messages/
      {msgId1}: {senderId, senderName, message, timestamp, isRead}
      {msgId2}: {...}
```

---

## 🔌 Repository Layer

### 1. **AuthRepository** (`lib/data/repositories/auth_repository.dart`)

**Responsibilities:**
- User registration with email verification
- User login with email verification check
- User logout
- Password reset
- Email verification resend
- User profile management

**Key Methods:**
```dart
// Authentication
Future<UserModel> signUp({
  required String email,
  required String password,
  required String displayName,
})

Future<UserModel> login({
  required String email,
  required String password,
})

Future<void> logout()

// Verification
Future<void> resendEmailVerification()

// Profile
Future<UserModel?> getCurrentUserProfile()
Future<void> updateUserProfile({
  required String displayName,
  String? profileImageUrl,
})

// Real-time Auth State
Stream<User?> getAuthStateChanges()
User? getCurrentUser()
```

**Firebase Interactions:**
- Uses `FirebaseAuth` for authentication
- Creates user profiles in `users` collection
- Stores profile images in `Firebase Storage`

### 2. **BookRepository** (`lib/data/repositories/book_repository.dart`)

**Responsibilities:**
- Create, read, update, delete books
- Stream books for real-time updates
- Search books

**Key Methods:**
```dart
// CRUD Operations
Future<String> createBook(BookModel book)
Future<void> updateBook(String bookId, BookModel book)
Future<void> deleteBook(String bookId)
Future<BookModel?> getBook(String bookId)

// Streams (Real-time)
Stream<List<BookModel>> getAllBooks()
Stream<List<BookModel>> getUserBooks(String userId)
Stream<List<BookModel>> getBookSwaps(String bookId)

// Search
Future<List<BookModel>> searchBooks(String query)
```

**Firestore Structure:**
```
books/
  {bookId1}: {title, author, condition, userId, createdAt, ...}
  {bookId2}: {...}
```

**Indexes:**
- `books` - orderBy `createdAt` (descending)
- `books` - where `userId`, orderBy `createdAt`

### 3. **SwapRepository** (`lib/data/repositories/swap_repository.dart`)

**Responsibilities:**
- Create swap offers
- Update swap status
- Track user's swaps (sent and received)
- Get all swaps for a book

**Key Methods:**
```dart
// CRUD
Future<String> createSwap(SwapModel swap)
Future<void> updateSwapStatus(String swapId, String status)
Future<void> deleteSwap(String swapId)
Future<SwapModel?> getSwap(String swapId)

// Streams (Real-time)
Stream<List<SwapModel>> getUserSwaps(String userId)      // Sent
Stream<List<SwapModel>> getReceivedSwaps(String userId)  // Received
Stream<List<SwapModel>> getBookSwaps(String bookId)
Stream<List<SwapModel>> getAllSwaps()
```

**Firestore Structure:**
```
swaps/
  {swapId1}: {bookId, senderUserId, recipientUserId, status, createdAt, ...}
  {swapId2}: {...}
```

**Indexes:**
- `swaps` - where `senderUserId`, orderBy `createdAt`
- `swaps` - where `recipientUserId`, orderBy `createdAt`
- `swaps` - where `bookId`

### 4. **ChatRepository** (`lib/data/repositories/chat_repository.dart`)

**Responsibilities:**
- Create or retrieve chat threads
- Send and receive messages
- Manage chat threads

**Key Methods:**
```dart
// Thread Management
Future<String> getOrCreateChatThread({
  required String userId1,
  required String userId1Name,
  required String userId2,
  required String userId2Name,
  String? swapId,
})
Future<ChatThread?> getChatThread(String threadId)
Future<void> deleteChatThread(String threadId)

// Messaging
Future<void> sendMessage({
  required String threadId,
  required ChatMessage message,
})
Stream<List<ChatMessage>> getMessages(String threadId)

// Streams
Stream<List<ChatThread>> getUserChatThreads(String userId)
```

**Firestore Structure:**
```
chatThreads/
  {threadId1}/
    (metadata fields)
    messages/
      {msgId1}: {senderId, message, timestamp, ...}
      {msgId2}: {...}
  {threadId2}: {...}
```

---

## 🎯 Provider Layer (State Management)

### 1. **AuthProvider** (`lib/presentation/providers/auth_provider.dart`)

**State:**
```dart
UserModel? _currentUser        // Current logged-in user
bool _isLoading                // Loading state
String? _error                 // Error messages
```

**Methods:**
```dart
Future<void> signUp({...})
Future<void> login({...})
Future<void> logout()
Future<void> checkAuthStatus()
Future<void> updateUserProfile({...})
Future<void> resendEmailVerification()
```

**Listeners:**
- Watches authentication state via Firebase
- Automatically syncs user profile

### 2. **BookProvider** (`lib/presentation/providers/book_provider.dart`)

**State:**
```dart
List<BookModel> _allBooks      // All books in marketplace
List<BookModel> _userBooks     // Current user's books
BookModel? _selectedBook       // Detailed view
bool _isLoading
String? _error
```

**Methods:**
```dart
void listenToAllBooks()
void listenToUserBooks(String userId)
Future<String> createBook(BookModel book)
Future<void> updateBook(String bookId, BookModel book)
Future<void> deleteBook(String bookId)
Future<void> getBook(String bookId)
Future<List<BookModel>> searchBooks(String query)
```

**Real-time Updates:**
- Listens to `getAllBooks()` stream
- Updates `_allBooks` whenever books are added/modified
- Listens to `getUserBooks()` for user's books

### 3. **SwapProvider** (`lib/presentation/providers/swap_provider.dart`)

**State:**
```dart
List<SwapModel> _userSwaps     // Offers sent by user
List<SwapModel> _receivedSwaps // Offers received by user
bool _isLoading
String? _error
```

**Methods:**
```dart
void listenToUserSwaps(String userId)
void listenToReceivedSwaps(String userId)
Future<void> createSwap(SwapModel swap)
Future<void> acceptSwap(String swapId)
Future<void> rejectSwap(String swapId)
Future<void> completeSwap(String swapId)
```

**Real-time Updates:**
- Listens to both sent and received swaps
- Auto-updates when swap status changes

### 4. **ChatProvider** (`lib/presentation/providers/chat_provider.dart`)

**State:**
```dart
List<ChatThread> _chatThreads  // All active chat threads
List<ChatMessage> _messages    // Messages in current thread
bool _isLoading
String? _error
```

**Methods:**
```dart
void listenToUserChats(String userId)
Future<void> getOrCreateThread({...})
Future<void> sendMessage({...})
Future<void> loadMessages(String threadId)
```

**Real-time Updates:**
- Listens to user's chat threads
- Updates whenever new messages arrive

---

## 🔄 Data Flow Example: Posting a Book

```
1. User fills form → Post Book Page
   ↓
2. User taps "Post" → BookProvider.createBook()
   ↓
3. BookProvider calls BookRepository.createBook()
   ↓
4. BookRepository uploads to Firestore
   ├─ Generate unique ID
   ├─ Upload book data
   └─ Return ID to provider
   ↓
5. BookProvider notifies listeners
   ↓
6. UI updates (Success message)
   ↓
7. Browse Page listens to getAllBooks() stream
   ├─ Firestore emits update
   ├─ BookProvider receives new list
   └─ UI auto-rebuilds with new book
```

---

## 🔐 Firebase Security Rules

### Authentication
- Only users with verified email can login
- Passwords must be ≥6 characters
- User profiles auto-created on signup

### Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Anyone can read books, only owner can modify
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if resource.data.userId == request.auth.uid;
    }
    
    // Similar rules for swaps, chats
    match /swaps/{swapId} {
      allow read: if request.auth.uid in [
        resource.data.senderUserId,
        resource.data.recipientUserId
      ];
      allow create: if request.auth != null;
      allow update: if request.auth.uid in [
        resource.data.senderUserId,
        resource.data.recipientUserId
      ];
    }
  }
}
```

---

## 🚀 Backend Implementation Checklist

### Phase 1: Authentication (COMPLETE ✅)
- [x] SignUp with email verification
- [x] Login with verified email check
- [x] Logout functionality
- [x] User profile creation
- [x] Password reset email

### Phase 2: Books (COMPLETE ✅)
- [x] Create book listing
- [x] Read books (single, all, user's)
- [x] Update book details
- [x] Delete book
- [x] Real-time streams
- [x] Search functionality

### Phase 3: Swaps (COMPLETE ✅)
- [x] Create swap offer
- [x] Accept/Reject swaps
- [x] Track swap status
- [x] Real-time swap updates
- [x] Get user's swaps (sent & received)

### Phase 4: Chat (COMPLETE ✅)
- [x] Create chat threads
- [x] Send messages
- [x] Receive messages
- [x] Real-time message stream
- [x] Get user's chat threads

### Phase 5: Testing & Optimization
- [ ] Unit tests for repositories
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Error handling enhancement
- [ ] Offline sync (Future)

---

## 📊 Database Schema Summary

```
├── users/
│   ├── {userId}
│   │   ├── id, email, displayName
│   │   ├── profileImageUrl, emailVerified
│   │   └── createdAt
│
├── books/
│   ├── {bookId}
│   │   ├── id, title, author, condition
│   │   ├── coverImageUrl, userId, userName
│   │   └── createdAt
│
├── swaps/
│   ├── {swapId}
│   │   ├── id, bookId
│   │   ├── senderUserId, senderUserName
│   │   ├── recipientUserId, recipientUserName
│   │   ├── status, createdAt
│   │   └── updatedAt
│
└── chatThreads/
    ├── {threadId}
    │   ├── userId1, userId1Name
    │   ├── userId2, userId2Name
    │   ├── swapId, createdAt
    │   ├── lastMessage, lastMessageAt
    │   └── messages/ (subcollection)
    │       ├── {msgId}
    │       │   ├── senderId, senderName
    │       │   ├── recipientId
    │       │   ├── message, timestamp, isRead
```

---

## 🔗 API Reference

All backend methods are accessible through providers in the presentation layer:

```dart
// In any widget:
context.read<AuthProvider>().login(email, password);
context.read<BookProvider>().createBook(bookModel);
context.read<SwapProvider>().acceptSwap(swapId);
context.read<ChatProvider>().sendMessage(threadId, message);
```

---

**Status:** ✅ Backend Fully Implemented and Ready for Testing  
**Version:** 1.0.0
