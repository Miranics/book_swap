import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'core/theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/book_repository.dart';
import 'data/repositories/swap_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/book_provider.dart';
import 'presentation/providers/swap_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnvironment();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _initializeSupabase();
  } catch (e) {
    print('Initialization error: $e');
  }
  
  runApp(const MyApp());
}

Future<void> _loadEnvironment() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    throw Exception('Environment file load error: $e');
  }
}

Future<void> _initializeSupabase() async {
  final String? supabaseUrl = dotenv.env['SUPABASE_URL'];
  final String? supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Supabase credentials missing. Check your .env file.');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final String storageBucketName =
        dotenv.env['SUPABASE_BUCKET'] ?? 'book-covers';

    return MultiProvider(
      providers: [
        // Repositories
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<BookRepository>(create: (_) => BookRepository()),
        Provider<SwapRepository>(create: (_) => SwapRepository()),
        Provider<ChatRepository>(create: (_) => ChatRepository()),
        Provider<StorageService>(
          create: (_) => StorageService(
            client: Supabase.instance.client,
            bucketName: storageBucketName,
          ),
        ),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<BookProvider>(
          create: (context) => BookProvider(
            context.read<BookRepository>(),
            context.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider<SwapProvider>(
          create: (context) => SwapProvider(context.read<SwapRepository>()),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(
            context.read<ChatRepository>(),
            context.read<AuthRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'BookSwap',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Check if user is logged in
            if (authProvider.isAuthenticated) {
              // Initialize listeners after user logs in
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (authProvider.currentUser != null) {
                  context.read<BookProvider>().listenToAllBooks();
                  context.read<BookProvider>().listenToUserBooks(authProvider.currentUser!.id);
                  context.read<SwapProvider>().listenToUserSwaps(authProvider.currentUser!.id);
                  context.read<SwapProvider>().listenToReceivedSwaps(authProvider.currentUser!.id);
                  context.read<ChatProvider>().listenToUserChats(authProvider.currentUser!.id);
                }
              });
              return const HomePage();
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
