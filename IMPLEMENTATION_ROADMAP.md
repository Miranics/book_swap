# BookSwap Implementation Roadmap

## Current Status: ✅ 60% Complete

### Foundation (100% Complete ✅)
- [x] Project structure with clean architecture
- [x] Firebase setup with authentication
- [x] Provider state management setup
- [x] Theme configuration (Dark Navy + Golden)
- [x] Repositories for all data operations
- [x] Models for all entities

### Authentication (100% Complete ✅)
- [x] Signup page with validation
- [x] Email verification enforcement
- [x] Login page with verification check
- [x] Logout functionality
- [x] User profile creation in Firestore

### Navigation (100% Complete ✅)
- [x] BottomNavigationBar with 4 screens
- [x] Browse Listings page skeleton
- [x] My Listings page skeleton
- [x] Chats page skeleton
- [x] Settings page with profile info

---

## Next Steps to Complete the Assignment

### 🔴 HIGH PRIORITY - Book CRUD (Should be 90% done)

#### What's Missing:
1. **Browse Page** - Show real book listings
2. **Post Book Page** - Form validation and submission
3. **Edit Book** - Pass book to form and update
4. **Delete Book** - Confirmation dialog
5. **Book Details** - Tap to view full details

#### Implementation Guide:

**Step 1: Test Book Creation**
```dart
// In PostBookPage, test this flow:
1. Fill form with test data
2. Click "Post Book"
3. Check Firestore console → books collection
4. Verify book created with all fields
5. Return to Browse page
```

**Step 2: Make Browse Page Reactive**
```dart
// browse_page.dart should show real books:
- Consumer<BookProvider> listens to state
- When BrowsePage loads, call:
  context.read<BookProvider>().listenToAllBooks()
- ListView.builder displays books
- Tap book → navigate to details (TODO)
```

**Step 3: Implement My Listings Edit/Delete**
```dart
// my_listings_page.dart already has popup menu
- Edit: Navigator.push → PostBookPage(bookToEdit: book)
- Delete: Show dialog → confirm → delete
- Both trigger provider methods that sync to Firestore
```

---

### 🟡 MEDIUM PRIORITY - Swap Functionality (Should be 50% done)

#### What's Needed:
1. **Browse Page Add Swap Button** on each book listing
2. **Swap Confirmation Dialog** - confirm before sending offer
3. **My Offers Screen** - show pending swaps  
4. **Swap Status Display** - Pending/Accepted/Rejected
5. **Accept/Reject Buttons** on received offers

#### Implementation Steps:

**Step 1: Create Swap Offer**
```dart
// In book details or browse long-press:
1. Show dialog: "Swap this book?"
2. context.read<SwapProvider>().createSwap(swapModel)
3. SwapModel.senderUserId = current user
4. SwapModel.recipientUserId = book owner
5. SwapModel.status = "pending"
6. Firestore stores it
```

**Step 2: Display User's Offers**
```dart
// New screen or part of my_listings_page:
1. Get swaps from SwapProvider.userSwaps
2. Show list of pending offers user made
3. Each item shows:
   - Book title
   - Recipient name
   - Status badge (Pending/Accepted)
```

**Step 3: Show Received Offers**
```dart
// New "My Offers" tab or separate page:
1. Get swaps from SwapProvider.receivedSwaps
2. Show books that others want to swap for
3. Buttons: Accept / Reject
4. Clicking updates Firestore: status → "accepted"/"rejected"
```

---

### 🟢 BONUS - Chat System (Optional but required for full marks)

#### What's Needed:
1. **Create Chat Thread** when swap is accepted
2. **Chat Screen** - list of conversations
3. **Message Input** - send messages
4. **Message Display** - show conversation
5. **Real-time Updates** - messages appear instantly

#### Implementation Steps:

**Step 1: Start Chat After Swap**
```dart
// When swap accepted:
1. context.read<ChatProvider>().getOrCreateChatThread(
      userId1: senderUserId,
      userId1Name: senderName,
      userId2: recipientUserId,
      userId2Name: recipientName,
      swapId: swapId,
    )
2. Returns threadId
3. Navigate to ChatDetailPage(threadId)
```

**Step 2: Chat Screen Layout**
```
┌─────────────────────────┐
│ John Doe          Close │ ← Header with other user
├─────────────────────────┤
│ [Messages list]         │
│                         │
│  Jane: "Great!"         │
│  John: "When can we"    │
│  "meet?"                │
├─────────────────────────┤
│ [Type message...] [Send]│ ← Message input
└─────────────────────────┘
```

**Step 3: Send/Receive Messages**
```dart
// Send message:
final message = ChatMessage(
  senderId: currentUserId,
  senderName: currentUserName,
  recipientId: otherUserId,
  message: textController.text,
  timestamp: DateTime.now(),
);

context.read<ChatProvider>().sendMessage(
  threadId: threadId,
  message: message,
);

// Firestore stores in:
// chatThreads/{threadId}/messages/{messageId}

// Receive (real-time):
// ChatProvider listens to messages subcollection
// Messages stream displayed in ListView
```

---

## Code Templates

### Template 1: Add Swap Button to Browse Page

```dart
// In browse_page.dart ListView.builder trailing:
ActionChip(
  label: const Text('Swap'),
  backgroundColor: AppTheme.accentColor,
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offer Swap'),
        content: Text('Want to swap for ${book.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final currentUser = context.read<AuthProvider>().currentUser;
                if (currentUser == null) return;

                final swap = SwapModel(
                  id: '',
                  senderUserId: currentUser.id,
                  senderUserName: currentUser.displayName ?? 'Unknown',
                  recipientUserId: book.userId,
                  recipientUserName: book.userName,
                  bookId: book.id,
                  bookTitle: book.title,
                  status: SwapStatus.pending,
                  createdAt: DateTime.now(),
                );

                await context.read<SwapProvider>().createSwap(swap);
                
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Swap offer sent!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Swap'),
          ),
        ],
      ),
    );
  },
),
```

### Template 2: Create My Offers Screen

```dart
// Create: lib/presentation/pages/my_offers_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../providers/swap_provider.dart';

class MyOffersPage extends StatelessWidget {
  const MyOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Offers')),
      body: Consumer<SwapProvider>(
        builder: (context, swapProvider, child) {
          if (swapProvider.userSwaps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 64, color: AppTheme.lightTextColor),
                  const SizedBox(height: 16),
                  const Text('No active offers'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: swapProvider.userSwaps.length,
            itemBuilder: (context, index) {
              final swap = swapProvider.userSwaps[index];
              return Card(
                child: ListTile(
                  title: Text(swap.bookTitle),
                  subtitle: Text('To: ${swap.recipientUserName}'),
                  trailing: Chip(
                    label: Text(swap.status.displayName),
                    backgroundColor: swap.status == SwapStatus.pending
                        ? AppTheme.warningColor.withOpacity(0.3)
                        : AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Template 3: Create Chat Screen

```dart
// Create: lib/presentation/pages/chat_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../domain/models/chat_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatDetailPage extends StatefulWidget {
  final String threadId;
  final String otherUserName;

  const ChatDetailPage({
    super.key,
    required this.threadId,
    required this.otherUserName,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatProvider>().listenToMessages(widget.threadId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final message = ChatMessage(
      id: '',
      senderId: currentUser.id,
      senderName: currentUser.displayName ?? 'Unknown',
      recipientId: '', // Will be determined by thread
      message: _messageController.text,
      timestamp: DateTime.now(),
    );

    context.read<ChatProvider>().sendMessage(
      threadId: widget.threadId,
      message: message,
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  reverse: true,
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[
                        chatProvider.messages.length - 1 - index];
                    final isMe = message.senderId ==
                        context.read<AuthProvider>().currentUser?.id;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.accentColor : AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(message.message),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.accentColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Testing Checklist

Before submitting, verify:

### Authentication ✅
- [ ] Signup with invalid email shows error
- [ ] Signup with password < 6 chars shows error
- [ ] Valid signup sends verification email
- [ ] Cannot login until email verified
- [ ] Login with wrong password shows error
- [ ] Logout clears user state
- [ ] Settings shows current user profile

### Book Listings
- [ ] Can post a book with all fields
- [ ] Posted book appears in Browse page
- [ ] Posted book appears in My Listings
- [ ] Can edit own book
- [ ] Can delete own book
- [ ] Book updates/deletion reflected immediately in both pages
- [ ] Cannot edit/delete other user's books

### Swaps
- [ ] Can send swap offer on other user's book
- [ ] Swap appears in My Offers as "Pending"
- [ ] Recipient sees it in their offers inbox
- [ ] Can accept/reject swap
- [ ] Status changes reflected in real-time

### Chats (if implemented)
- [ ] Chat thread creates on swap acceptance
- [ ] Can send/receive messages
- [ ] Messages persist
- [ ] Messages appear in real-time

---

## Firebase Console Verification

### Verify in Firebase Console:

1. **Authentication**
   - [ ] See created users
   - [ ] Email verification status visible

2. **Firestore**
   - [ ] Check collections: users, books, swaps, chatThreads
   - [ ] Verify document structure matches schema
   - [ ] Check indexes for queries

3. **Database Rules**
   - [ ] Users can only modify their own docs
   - [ ] Books readable by all, editable by owner
   - [ ] Swaps/Chats have proper access control

---

## Video Demo Checklist (7-12 minutes)

Record showing:

1. **Authentication (1-2 min)**
   - [ ] Signup form
   - [ ] Email verification
   - [ ] Login attempt before verification
   - [ ] Login after verification
   - [ ] Firebase console showing user created

2. **Book CRUD (2-3 min)**
   - [ ] Post new book
   - [ ] See in browse feed
   - [ ] Edit book
   - [ ] See changes in real-time
   - [ ] Delete book
   - [ ] Firebase console showing documents

3. **Swap Offers (1-2 min)**
   - [ ] Tap swap on another user's book
   - [ ] Swap appears in "My Offers" as Pending
   - [ ] Firebase console showing swap created
   - [ ] Accept/Reject swap
   - [ ] Status changes

4. **Navigation (1 min)**
   - [ ] Tap through all 4 tabs
   - [ ] Settings shows profile
   - [ ] Logout works

5. **Chat (1-2 min if implemented)**
   - [ ] Chat thread creates
   - [ ] Send message
   - [ ] Receive message
   - [ ] Real-time sync

---

## Final Submission Checklist

- [ ] All code committed with clear messages
- [ ] README.md with setup instructions
- [ ] DESIGN_SUMMARY.md (1-2 pages, architecture + decisions)
- [ ] Dart analyzer shows ≤ 10 info warnings (no errors)
- [ ] 7-12 minute demo video recorded
- [ ] Reflection PDF with:
  - [ ] 2+ Firebase error screenshots (with resolutions)
  - [ ] Dart analyzer report screenshot
- [ ] GitHub repo pushed
- [ ] All files in PDF document

---

## Need Help?

### Common Issues & Solutions

**Issue:** "Email not verified" on login
- **Solution:** Check Firebase Auth console, resend verification email

**Issue:** Real-time updates not working
- **Solution:** Check Firestore security rules, ensure listener is active

**Issue:** Images not uploading
- **Solution:** Create Firebase Storage bucket, add rules, implement image_picker

**Issue:** Build failures
- **Solution:** Run `flutter clean` then `flutter pub get`

---

**Good luck! You're on the right track! 🚀**
