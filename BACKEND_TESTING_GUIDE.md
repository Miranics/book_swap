# BookSwap Backend Testing Guide

## 🧪 Testing the Complete Backend Implementation

This guide walks through testing all backend features to ensure they work correctly with Firebase.

---

## 📋 Pre-Test Setup

### Firebase Project Configuration

Before testing, ensure your Firebase project is properly configured:

#### 1. **Enable Authentication Methods**
   - Go to Firebase Console → Authentication → Sign-in methods
   - Enable **Email/Password** authentication
   - Enable **Email link sign-in** (optional)

#### 2. **Create Firestore Database**
   - Go to Firebase Console → Firestore Database
   - Select **Start in production mode**
   - Choose a region (e.g., `us-central1`)

#### 3. **Set Up Storage for Images**
   - Go to Firebase Console → Storage
   - Create a bucket for book cover images
   - Note the bucket name for Firebase configuration

#### 4. **Configure Security Rules**
   - Replace Firestore rules with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Books collection - readable by all, modifiable by owner
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if resource.data.userId == request.auth.uid;
    }
    
    // Swaps collection
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
    
    // Chat threads and messages
    match /chatThreads/{threadId} {
      allow read: if request.auth.uid in [
        resource.data.userId1,
        resource.data.userId2
      ];
      allow create: if request.auth != null;
      allow update: if request.auth.uid in [
        resource.data.userId1,
        resource.data.userId2
      ];
      
      match /messages/{messageId} {
        allow read: if request.auth.uid in [
          get(/databases/$(database)/documents/chatThreads/$(threadId)).data.userId1,
          get(/databases/$(database)/documents/chatThreads/$(threadId)).data.userId2
        ];
        allow create: if request.auth != null;
      }
    }
  }
}
```

---

## ✅ Test Cases

### **Test 1: Authentication Flow**

#### 1.1 User Signup
```
Steps:
1. Launch app → See LoginPage
2. Tap "Sign Up" → Go to SignupPage
3. Enter:
   - Email: test1@example.com
   - Password: Password123!
   - Name: John Doe
4. Tap "Sign Up"

Expected Results:
✅ User created in Firebase Authentication
✅ User profile created in Firestore users collection
✅ Verification email sent
✅ Show message: "Verification email sent..."
✅ User NOT logged in yet (pending email verification)
```

#### 1.2 Email Verification
```
Steps:
1. Check email for verification link
2. Click the link (or use Firebase Console to manually verify)
3. In Firebase Console:
   - Go to Authentication → Users
   - Find test1@example.com → Custom Claims
   - Verify email is marked as verified

Expected Results:
✅ Email marked as verified in Firebase
```

#### 1.3 User Login
```
Steps:
1. App shows LoginPage (user not verified yet)
2. Enter credentials:
   - Email: test1@example.com
   - Password: Password123!
3. Tap "Sign In"

Expected Results:
✅ Login fails with message: "Email not verified"
   (Until email is verified)
✅ After email verification, login succeeds
✅ Navigate to HomePage
✅ User profile loaded from Firestore
```

#### 1.4 Logout
```
Steps:
1. From Settings page (4th tab)
2. Scroll to bottom
3. Tap "Logout" → Confirm

Expected Results:
✅ User logged out
✅ Navigate back to LoginPage
✅ AuthProvider.currentUser = null
```

---

### **Test 2: Book Management**

#### 2.1 Create Book Listing
```
Steps:
1. Login as user
2. Home page → tap "My Listings" tab
3. Tap "Post" button
4. Enter:
   - Title: "Data Structures & Algorithms"
   - Author: "Cormen & Leiserson"
   - Swap For: "Machine Learning books"
   - Condition: Select "Like New"
5. Tap "Post"

Expected Results:
✅ Book added to Firestore (books collection)
✅ Book has userId = current user's ID
✅ Book appears in Browse page instantly
✅ Book appears in "My Listings" with latest timestamp
✅ Success message shown
```

**Verify in Firestore:**
```
books/
  {generatedId}/
    title: "Data Structures & Algorithms"
    author: "Cormen & Leiserson"
    condition: "likeNew"
    userId: "user123" (current user)
    userName: "John Doe"
    createdAt: "2025-11-08T..."
    coverImageUrl: null (no image uploaded yet)
```

#### 2.2 Browse Books
```
Steps:
1. Home page → tap "Browse" tab
2. Scroll through list

Expected Results:
✅ See all books from all users
✅ Display book with:
   - Cover image (or placeholder)
   - Title
   - Author
   - Condition badge
   - Posted time (e.g., "2 days ago")
✅ Books ordered by newest first
```

#### 2.3 Edit Book
```
Steps:
1. My Listings tab
2. Find your book
3. Long-press or swipe → Edit
4. Change:
   - Condition: "Good"
5. Tap "Update"

Expected Results:
✅ Book updated in Firestore
✅ Changes reflected instantly in UI
✅ Updated timestamp changed
```

#### 2.4 Delete Book
```
Steps:
1. My Listings tab
2. Find your book
3. Swipe right → Delete
4. Confirm deletion

Expected Results:
✅ Book deleted from Firestore
✅ Removed from UI instantly
✅ No longer appears in Browse
```

#### 2.5 Search Books
```
Steps:
1. Browse tab
2. Search bar → Type "Data Structures"
3. See filtered results

Expected Results:
✅ Only books with matching title appear
✅ Real-time filtering as you type
```

---

### **Test 3: Swap System**

#### 3.1 Create Swap Offer
```
Steps:
1. Browse tab → See another user's book
2. Tap book → "Interested?" button
3. Dialog shows:
   - Book title
   - Owner name
4. Tap "Yes, I'm Interested!"
5. Select one of your books to swap
6. Tap "Make Offer"

Expected Results:
✅ Swap record created in Firestore
✅ Status = "pending"
✅ Sender ID = current user
✅ Recipient ID = book owner
✅ Success message
✅ Swap appears in "My Swaps" (Pending)
```

**Verify in Firestore:**
```
swaps/
  {swapId}/
    bookId: "book456"
    senderUserId: "currentUserId"
    senderUserName: "John Doe"
    recipientUserId: "otherUserId"
    recipientUserName: "Jane Smith"
    status: "pending"
    createdAt: "2025-11-08T..."
```

#### 3.2 Receive Swap Offer
```
Steps:
1. Login as book owner (other user account)
2. Open app → See notification or...
3. Tap "Chats" tab → See new swap offer

Expected Results:
✅ New swap visible in received swaps list
✅ Shows sender info and books
✅ Status = "pending"
```

#### 3.3 Accept Swap
```
Steps:
1. Received Swaps → Find pending swap
2. Tap "Accept"

Expected Results:
✅ Swap status updated to "accepted"
✅ Chat thread created automatically
✅ Both users can now message about swap
✅ Move to "Active Swaps"
```

#### 3.4 Reject Swap
```
Steps:
1. Received Swaps → Find pending swap
2. Tap "Reject"

Expected Results:
✅ Swap status updated to "rejected"
✅ Removed from active swaps
✅ Sender gets notification (in future enhancement)
```

---

### **Test 4: Chat System**

#### 4.1 Send Message
```
Steps:
1. After accepting a swap, tap "Chat"
2. Type message: "When can we meet?"
3. Tap "Send"

Expected Results:
✅ Message appears in chat instantly
✅ Message added to Firestore
✅ Timestamp recorded
✅ Sender ID = current user
✅ Thread's lastMessage updated
```

**Verify in Firestore:**
```
chatThreads/{threadId}/messages/
  {msgId}/
    senderId: "user1"
    senderName: "John Doe"
    recipientId: "user2"
    message: "When can we meet?"
    timestamp: "2025-11-08T12:30:00Z"
    isRead: false
```

#### 4.2 Receive Message
```
Steps:
1. Other user sends a message
2. Current user's app shows new message

Expected Results:
✅ Message appears in chat thread
✅ Real-time update (no need to refresh)
✅ Message ordered chronologically
✅ User avatar shows sender
```

#### 4.3 Chat Thread List
```
Steps:
1. Tap "Chats" tab
2. See list of all active chat threads

Expected Results:
✅ Show all users you're chatting with
✅ Display last message preview
✅ Show timestamp of last message
✅ Ordered by most recent first
```

---

### **Test 5: Real-Time Synchronization**

#### 5.1 Multi-Device Sync
```
Steps:
1. Open app on Device A
2. Post a book
3. Device B (same user):
   - My Listings tab refreshes automatically

Expected Results:
✅ New book appears on Device B
✅ No manual refresh needed
✅ Demonstrating real-time Firestore streams
```

#### 5.2 Another User Sees Your Book
```
Steps:
1. Device A: Create book "Operating Systems"
2. Device B (different user):
   - Browse tab
   - New book appears instantly

Expected Results:
✅ Book visible to other users in real-time
```

#### 5.3 Swap Status Updates
```
Steps:
1. Device A: Send swap offer
2. Device B: Accept swap
3. Device A: Swaps status changes from "pending" → "accepted"

Expected Results:
✅ Status updated without refresh
✅ Real-time listener notifies provider
✅ UI rebuilds automatically
```

---

## 🐛 Troubleshooting

### Issue: "Email not verified" but I clicked the link
**Solution:**
- Firebase verification links expire after 24 hours
- Click "Resend verification email" on login page
- Check spam folder
- Use Firebase Console to manually verify:
  1. Go to Authentication → Users
  2. Click user
  3. Click "Custom Claims" tab
  4. Set `emailVerified: true` (for testing only)

### Issue: Books not appearing in Browse
**Solution:**
- Check Firestore database is created
- Verify security rules allow `read` for authenticated users
- Check `firebase_core` is properly initialized
- Look at console logs: `flutter logs`

### Issue: Messages not sending
**Solution:**
- Verify chat threads exist in Firestore
- Check `chatThreads/{threadId}/messages` subcollection exists
- Verify user IDs match in both chat participants
- Check storage quota not exceeded

### Issue: Swap offers not updating
**Solution:**
- Verify `swaps` collection queries are indexed
- Check Firestore rules allow read/write for swap participants
- Ensure `senderUserId` and `recipientUserId` match current users

### Issue: App crashes on startup
**Solution:**
```bash
# Check for errors
flutter logs

# Rebuild app
flutter clean
flutter pub get
flutter run
```

---

## 📊 Performance Testing

### Test 1: Load 100 Books
```
Steps:
1. Create 100 books manually or via Firebase Console
2. Open Browse tab
3. Scroll through all books

Expected Results:
✅ Smooth scrolling (60 FPS)
✅ Lazy loading if list is very long
✅ No memory leaks
```

### Test 2: Chat with Many Messages
```
Steps:
1. Send 100+ messages in a chat
2. Scroll through chat history

Expected Results:
✅ Quick load time (<1 second)
✅ Smooth scrolling
✅ Messages ordered correctly
```

---

## ✅ Final Verification Checklist

Run through this checklist to ensure everything works:

```
AUTHENTICATION
✅ Signup creates user and sends verification email
✅ Login requires verified email
✅ Logout clears session
✅ Email verification works
✅ Password reset works (future)

BOOKS
✅ Can create book
✅ Can view all books
✅ Can view own books
✅ Can update book
✅ Can delete book
✅ Books appear in real-time
✅ Search works

SWAPS
✅ Can create swap offer
✅ Can view received offers
✅ Can accept swap
✅ Can reject swap
✅ Swap status updates real-time
✅ Chat thread auto-created on accept

CHATS
✅ Can send message
✅ Messages appear real-time
✅ Can see chat history
✅ Threads list shows correctly
✅ Last message preview works

DATABASE
✅ Users collection populated
✅ Books collection populated
✅ Swaps collection populated
✅ ChatThreads collection populated
✅ Security rules enforced
```

---

## 🚀 Next Steps After Testing

1. **User Testing**
   - Have real users test the app
   - Collect feedback on UX

2. **Performance Optimization**
   - Implement pagination for large lists
   - Add offline sync capability
   - Optimize image loading

3. **Feature Enhancements**
   - Add ratings/reviews
   - Add messaging notifications
   - Add book wish list
   - Add swap history

4. **Production Deployment**
   - Sign APK with production key
   - Upload to Google Play Store
   - Monitor analytics and errors

---

**Document Version:** 1.0  
**Last Updated:** November 8, 2025  
**Status:** Ready for Testing
