import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<BookRepository>(create: (_) => BookRepository()),
        Provider<SwapRepository>(create: (_) => SwapRepository()),
        Provider<ChatRepository>(create: (_) => ChatRepository()),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<BookProvider>(
          create: (context) => BookProvider(context.read<BookRepository>()),
        ),
        ChangeNotifierProvider<SwapProvider>(
          create: (context) => SwapProvider(context.read<SwapRepository>()),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(context.read<ChatRepository>()),
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
