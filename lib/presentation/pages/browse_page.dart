import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../providers/book_provider.dart';
import 'post_book_page.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PostBookPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.allBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books,
                    size: 64,
                    color: AppTheme.lightTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No books available yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookProvider.allBooks.length,
            itemBuilder: (context, index) {
              final book = bookProvider.allBooks[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: book.coverImageUrl != null
                      ? Image.network(
                          book.coverImageUrl!,
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          height: 75,
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                          child: const Icon(Icons.menu_book),
                        ),
                  title: Text(book.title),
                  subtitle: Text('by ${book.author}'),
                  trailing: Chip(
                    label: Text(book.condition.toFirestoreString()),
                    backgroundColor: AppTheme.accentColor.withOpacity(0.3),
                  ),
                  onTap: () {
                    // TODO: Navigate to book details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
