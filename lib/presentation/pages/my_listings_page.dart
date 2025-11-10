import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/models/swap_model.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import 'post_book_page.dart';
import 'swap_requests_page.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context) {

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
          final swapProvider = context.watch<SwapProvider>();

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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SwapRequestsPage(book: book),
                      ),
                    );
                  },
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('by ${book.author}'),
                      const SizedBox(height: 4),
                      _SwapSummaryChip(
                        swaps: swapProvider.receivedSwaps
                            .where((swap) => swap.bookId == book.id)
                            .toList(),
                      ),
                    ],
                  ),
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

class _SwapSummaryChip extends StatelessWidget {
  final List<SwapModel> swaps;

  const _SwapSummaryChip({required this.swaps});

  @override
  Widget build(BuildContext context) {
    if (swaps.isEmpty) {
      return Text(
        'No swap requests yet',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: AppTheme.lightTextColor),
      );
    }

    final pendingCount = swaps.where((swap) => swap.status == SwapStatus.pending).length;
    final acceptedCount = swaps.where((swap) => swap.status == SwapStatus.accepted).length;

    final segments = <String>[];
    if (pendingCount > 0) {
      segments.add('$pendingCount pending');
    }
    if (acceptedCount > 0) {
      segments.add('$acceptedCount accepted');
    }
    final statusText = segments.isEmpty
        ? '${swaps.length} request${swaps.length == 1 ? '' : 's'}'
        : segments.join(' • ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: AppTheme.primaryColor),
      ),
    );
  }
}
