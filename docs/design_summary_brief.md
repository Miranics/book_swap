# BookSwap Design Summary (Condensed)

> **Instructions for PDF submission**  
> This markdown captures everything requested for the 1–2 page design summary. Export it to PDF after replacing placeholder diagrams or adding your own figures if desired.

## 1. Data Modeling Overview

### 1.1 Firestore Collections

| Collection | Key fields | Purpose |
|------------|------------|---------|
| `users/{uid}` | `displayName`, `email`, `profileImageUrl`, `emailVerified`, `createdAt` | Stores verified profile info synchronized with Firebase Auth |
| `books/{bookId}` | `title`, `author`, `condition`, `coverImageUrl`, `userId`, `userName`, `createdAt`, `updatedAt` | Public marketplace listings with Supabase-hosted cover images |
| `swaps/{swapId}` | `senderUserId`, `recipientUserId`, `bookId`, `status`, `createdAt`, `updatedAt` | Tracks swap negotiations and state transitions |
| `chatThreads/{threadId}` | `userId1`, `userId2`, `swapId`, `lastMessage`, `lastMessageAt` | Summary document for each chat. Subcollection `messages/{messageId}` holds chat history |

> **Tip**: Add the ERD diagram placeholder here if you have one: `![BookSwap ERD](TODO_erd.png)`

### 1.2 Supabase Storage Bucket (`book-covers`)

- Object path format: `book_covers/<userId>/cover_<timestamp>.jpg`
- Public bucket with policies allowing anonymous `INSERT` and `SELECT`
- URLs stored in Firestore `books.coverImageUrl`

## 2. Swap State Modeling

### 2.1 Enum Definition

```dart
enum SwapStatus { pending, accepted, rejected, completed }
```

### 2.2 Firestore Document Representation

```json
{
  "status": "pending",
  "senderUserId": "uid_alice",
  "recipientUserId": "uid_bob",
  "bookId": "book_123",
  "createdAt": "2025-11-09T15:42:00Z",
  "updatedAt": "2025-11-09T15:42:00Z"
}
```

- Status strings (`pending`, `accepted`, `rejected`, `completed`) are generated via an extension method for consistency.
- `SwapProvider` listens to both sender and recipient swap streams so each device updates in real time.
- Accept / Reject actions update `status` and `updatedAt`, which triggers UI rebuilds via Provider.

## 3. State Management Approach

### 3.1 Provider Hierarchy

```
MyApp (MultiProvider)
 ├─ AuthProvider (AuthRepository)
 ├─ BookProvider (BookRepository + StorageService)
 ├─ SwapProvider (SwapRepository)
 └─ ChatProvider (ChatRepository)
```

- **AuthProvider** owns `UserModel` and guards routes based on `isAuthenticated`.
- **BookProvider** exposes streams for `allBooks` and `userBooks`, handles Supabase uploads, and bubbles errors to the UI.
- **SwapProvider** manages `pending`, `sent`, and `received` swaps.
- **ChatProvider** subscribes to Firestore chat threads and messages for real-time messaging.

### 3.2 Widget Consumption Pattern

- `HomePage` wraps body in `Consumer` widgets so each tab rebuilds only when its provider changes.
- Snackbars and loading indicators read provider `isLoading` flags to deliver user feedback.

## 4. Trade-offs & Challenges

| Challenge | Decision | Rationale |
|-----------|----------|-----------|
| Firebase Storage requires Blaze upgrade | Switched to Supabase for file hosting | Keeps project free-tier friendly while satisfying “cover image” requirement |
| Multiple real-time listeners | Scoped listeners to authenticated user in `main.dart` using `addPostFrameCallback` | Avoids redundant listeners before login and reduces Firestore reads |
| Chrome CanvasKit fetch failures | Forced HTML renderer via `<meta name="flutter-web-renderer" content="html">` | Guarantees compatibility in restricted lab networks |
| Windows username contains a space | Recommend running project from `C:\dev\book_swap` or using a junction | Prevents Gradle build path errors |

## 5. Future Enhancements

- Replace Supabase anonymous access with signed URLs once Storage billing is feasible.
- Add indexing rules in Firestore console (composite indexes for swap filters and book search).
- Integrate push notifications for accepted swaps and chat messages.
- Harden Firestore security rules before production (move from test mode to role-based checks).

---

**Export Reminder**: After embedding screenshots/diagrams, export this file to PDF and submit alongside the Firebase connection reflection.
