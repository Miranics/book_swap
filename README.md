git clone https://github.com/Miranics/book_swap.git
# BookSwap – Flutter + Firebase

BookSwap is a mobile marketplace where students list textbooks, propose swaps, and monitor each trade in real time. The project combines a Flutter front end, Firebase Authentication, and Cloud Firestore with Provider-based state management.

---

## Quick Feature Tour

- **Authentication:** Email/password signup, verification gate, login, logout, and profile snapshots.
- **Listings CRUD:** Create, browse, edit, and delete book cards with cover images, condition, and tags.
- **Swap Workflow:** Offer swaps, watch state changes (pending → accepted → delivered → completed/cancelled), and sync both parties instantly.
- **Chat (bonus):** Post-offer conversations stored in Firestore subcollections.
- **Settings:** Profile info, notification toggles, verification badges, and logout.

---

## Clean Architecture Layout

```
lib/
├── core/                  Shared utilities (theme, constants)
├── data/                  Firebase data sources + repositories
│   ├── models/            DTOs mapped from Firestore documents
│   └── repositories/      Firebase implementations
├── domain/                Pure models and use cases
├── presentation/          UI layer
│   ├── pages/             Screens grouped by feature
│   ├── providers/         ChangeNotifier classes (Provider)
│   └── widgets/           Reusable UI components
└── main.dart              Entry point + MultiProvider wiring
```

### State Management Snapshot

`Widget` ▶ subscribes to ▶ `ChangeNotifier` ▶ calls ▶ `Repository` ▶ reads/writes ▶ Firebase ▶ streams back ▶ `ChangeNotifier` ▶ notifies ▶ `Widget`

- `AuthProvider`: login, signup, verification, current user cache.
- `BookProvider`: listing CRUD and live query streams.
- `SwapProvider`: swap creation, timeline updates, status transitions.
- `ChatProvider`: message thread listeners per swap.

Zero shared mutable state lives outside Provider; any `setState` usage is limited to local UI toggles.

---

## Firestore Schema Overview

| Collection | Key fields | Purpose |
|------------|------------|---------|
| `users` | `displayName`, `email`, `photoUrl`, `completedSwaps`, `rating` | Profile cards + quick stats |
| `books` | `ownerUid`, `title`, `author`, `condition`, `coverUrl`, `tags`, `isAvailable` | Public listing feed |
| `swaps` | `requesterUid`, `ownerUid`, `bookId`, `state`, timeline array, timestamp fields | Swap lifecycle storage |
| `chatThreads` | `swapId`, `participants[]`, messages subcollection | Conversation per accepted swap |
| `notifications` | `userUid`, `type`, payload, `isRead` | In-app alerts (optional) |
| `wishlists` | `userUid`, `bookRefs[]` | Save-for-later support (optional) |

### Swap States

`requested → accepted → in_transit → delivered → completed` with `cancelled` exit. Each transition appends `{state, actorUid, timestamp}` to `timeline[]` for audits and powers the UI status chips.

### ERD

Check `docs/erd/bookswap_erd.png` (or generate from the Mermaid spec in `docs/erd/bookswap_erd.mmd`). The diagram matches the schema above and is embedded in the design PDF.

---

## Firebase Setup Checklist

1. Create a Firebase project and enable **Authentication (Email/Password)** and **Cloud Firestore** (production mode, same region as your Android/iOS builds).
2. Download config files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart` (via `flutterfire configure`)
3. Add web configuration to `web/index.html` if running in browser.
4. Update `.env` with storage buckets or API URLs if required (`cp .env.example .env`).
5. Apply Firestore security rules from `firebase/firestore.rules` and deploy (`firebase deploy --only firestore:rules`).
6. Pre-create composite indexes flagged during development. When Firestore raises a `failed-precondition`, follow the provided console link or run `firebase firestore:indexes:deploy` with `firebase/firestore.indexes.json`.

---

## Local Development

```bash
git clone https://github.com/Miranics/book_swap.git
cd book_swap

# Install Flutter packages
flutter pub get

# Generate any json_serializable files if added later
flutter pub run build_runner build --delete-conflicting-outputs

# Clean build folders when switching devices
flutter clean

# Run on Android (avoid directories with spaces on Windows)
flutter run -d <deviceId>

# Run analyzer (capture screenshot for submission)
flutter analyze
```

> **Windows tip:** Android builds fail if the project path contains spaces (e.g., `C:\Users\ALU MCF`). Move or clone the repo to a folder such as `C:\dev\book_swap` before running on a device.

---

## Testing & Quality

- **Analyzer:** `flutter analyze` should pass. Capture the terminal output for the assignment PDF.
- **Formatting:** `flutter format lib test` keeps the codebase consistent.
- **Smoke tests:** `flutter run -d chrome` is useful for quick UI checks, but the graded demo must run on an emulator or physical device.

---

## Deliverables Guide (assignment support)

1. **Reflection PDF:** Describe Firebase setup hurdles (include screenshots of dependency mismatch and missing index errors) and the fixes applied.
2. **Analyzer Screenshot:** Run `flutter analyze`, resolve issues, and capture the clean output.
3. **Design Summary PDF:** Reference the ERD, swap state timeline, Provider flow, and trade-offs (denormalized swap snapshots, listener vs. fetch, index maintenance).
4. **Demo Video (7–12 min):**
   - Keep app and Firebase console visible side-by-side.
   - Show auth signup → verification → login, book CRUD, swap offer and acceptance, navigation tabs, settings toggles, and chat if implemented.
   - Narrate why each step matters (state management, Firestore triggers).
5. **Repository hygiene:** incremental commits with descriptive messages, secrets excluded via `.gitignore`, and README kept current (this file).

---

## Notable Packages

```yaml
firebase_core: ^2.32.0
firebase_auth: ^4.16.0
cloud_firestore: ^4.17.5
firebase_storage: ^11.7.7
provider: ^6.0.0
image_picker: ^1.0.4
flutter_dotenv: ^5.2.1
intl: ^0.19.0
``` 

Run `flutter pub outdated` to inspect upgrade paths (many Firebase packages already have 6.x versions; bumping requires null-safety checks and is left for future work).

---

## Troubleshooting Notes

- **Path errors on Windows:** If Gradle complains about `Failed to create parent directory 'C:\Users\ALU\ MCF...'`, move the project to a space-free path.
- **Firestore missing index:** Follow the console link produced in the error or paste the definition into `firebase/firestore.indexes.json` and deploy.
- **Email verification:** Firebase does not automatically block unverified users; `AuthProvider` checks `user.emailVerified` and prevents navigation until the flag flips.
- **Deleted Firestore database:** Recreate the default database in the Firebase console, reapply rules/indexes, and seed baseline data via the app or scripted imports.

---

## Contribution & License

Pull requests and issues are welcome. Please open an issue describing the change before submitting large PRs to keep the roadmap aligned.

This project is released under the MIT License. See `LICENSE` for details.

---

Happy swapping! 🎓📚
