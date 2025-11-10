# Firebase & Supabase Integration Reflection

> **Instructions for PDF submission**  
> Export this document to PDF after replacing the screenshot placeholders with your actual images. In VS Code you can use the "Markdown PDF" extension or copy into Google Docs / Word and save as PDF.

## 1. Project Context

- **App**: BookSwap (Flutter 3.35.7)
- **Backend services**: Firebase Auth, Cloud Firestore, Supabase Storage (used instead of Firebase Storage to avoid Blaze billing requirement)
- **Platforms tested**: Chrome (HTML renderer) and Android physical device (TECNO KI5k)

## 2. Setup Experience Timeline

| Step | Action | Notes |
|------|--------|-------|
| 1 | Created Firebase project `bookswap-c8bb5` and enabled Email/Password Auth | Auth emails customized under *Authentication → Templates* |
| 2 | Ran `flutterfire configure` to generate `lib/firebase_options.dart` and `android/app/google-services.json` | Verified initialization in `main.dart`
| 3 | Enabled Firestore database in test mode | Created seed collections for `users`, `books`, `swaps`, `chatThreads`
| 4 | Encountered Chrome CanvasKit issues | Forced HTML renderer by adding `<meta name="flutter-web-renderer" content="html">` in `web/index.html`
| 5 | Firebase Storage upgrade prompt blocked uploads | Switched to Supabase public bucket `book-covers` with anonymous insert/select policies
| 6 | Connected Android device and resolved Gradle path issue by running from a directory without spaces | Debug build now runs from `flutter run -d <device>`

## 3. Key Errors & Fixes

> Replace each `TODO` with your screenshot path and update commentary with anything extra you observed during finals testing.

### 3.1 CanvasKit Fetch Error (Chrome)

- **Symptom**: `CanvasKit wasm` not loading when running `flutter run -d chrome`
- **Resolution**: Forced HTML renderer in `web/index.html`
- **Screenshot**: `![CanvasKit fetch error screenshot](TODO_canvaskit.png)`

### 3.2 Firebase Storage Requires Billing

- **Symptom**: Storage console demanded Blaze upgrade and uploads returned 403
- **Resolution**: Migrated uploads to Supabase Storage with anonymous `INSERT` and `SELECT` policies
- **Screenshot**: `![Firebase Storage billing prompt](TODO_storage_billing.png)`

### 3.3 Supabase 403 Policy Error

- **Symptom**: `StorageException: 403` when posting a book
- **Resolution**: Added Supabase policies
  ```sql
  create policy "Allow public uploads"
  on storage.objects
  for insert
  to public
  with check (bucket_id = 'book-covers' AND auth.role() = 'anon');

  create policy "Allow public reads"
  on storage.objects
  for select
  to public
  using (bucket_id = 'book-covers' AND auth.role() = 'anon');
  ```
- **Screenshot**: `![Supabase policy editor](TODO_supabase_policy.png)`

### 3.4 Gradle Build Fails Due to Space in Windows Username

- **Symptom**: `Failed to create parent directory 'C:\\Users\\ALU\ MCF\\.vscode'`
- **Resolution**: Use a junction or copy project to a folder without spaces (e.g., `C:\dev\book_swap`) and run `flutter clean`
- **Screenshot**: `![Gradle path error output](TODO_gradle_error.png)`

## 4. Dart Analyzer Report

1. Run `flutter analyze` from the project root.  
2. Capture the terminal output showing `No issues found!` (or the list of warnings if any).  
3. Add the screenshot below:

`![Dart analyzer output](TODO_analyzer.png)`

## 5. Testing Checklist

- [ ] Login requires verified email (tested with real verification link)
- [ ] Book posting with Supabase cover upload works on Chrome and Android
- [ ] Swap status changes (Pending → Accepted/Rejected) reflected in Firestore
- [ ] Chat messages appear in Firestore under `chatThreads/{threadId}/messages`
- [ ] Error snackbars show when network/storage policies fail

## 6. Lessons Learned

- Firebase Auth + Firestore covers all real-time needs, but Storage now requires Blaze for production projects.
- Supabase is a solid fallback for file uploads; anonymous policies must be explicit.
- Keep Flutter projects in directories without spaces to keep Gradle happy on Windows.
- Force the HTML renderer on Chrome if CanvasKit assets are blocked.

---

**Next actions before submission**

1. Replace all `TODO_*.png` placeholders with actual screenshot paths or inline images.
2. Export this markdown to PDF.
3. Place both PDF documents (this one and the design summary) in a `/submission` folder or attach directly to Blackboard/GitHub Classroom as required.
