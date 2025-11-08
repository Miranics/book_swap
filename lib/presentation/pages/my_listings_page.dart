import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import 'post_book_page.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PostBookPage(),
            ),
          );
        },
        child: const Icon(Icons.add, color: AppTheme.primaryColor),
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.userBooks.isEmpty) {
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
                    'You haven\'t posted any books yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PostBookPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Post Your First Book'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookProvider.userBooks.length,
            itemBuilder: (context, index) {
              final book = bookProvider.userBooks[index];
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
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostBookPage(bookToEdit: book),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Book'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<BookProvider>().deleteBook(book.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
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
