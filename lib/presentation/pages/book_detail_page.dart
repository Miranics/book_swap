import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/models/book_model.dart';
import '../../domain/models/swap_model.dart';
import '../providers/auth_provider.dart';
import '../providers/swap_provider.dart';

class BookDetailPage extends StatelessWidget {
  final BookModel book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isOwner = currentUser?.id == book.userId;
    final swapProvider = context.watch<SwapProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 320),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: book.coverImageUrl != null
                      ? Image.network(
                          book.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const _FallbackCover();
                          },
                        )
                      : const _FallbackCover(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              book.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'by ${book.author}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
            ),
            const SizedBox(height: 24),
            _DetailTile(
              icon: Icons.person,
              label: 'Listed by',
              value: book.userName,
            ),
            const SizedBox(height: 12),
            _DetailTile(
              icon: Icons.info_outline,
              label: 'Condition',
              value: book.condition.displayName,
            ),
            const SizedBox(height: 12),
            _DetailTile(
              icon: Icons.schedule,
              label: 'Posted',
              value: _formatPostedTime(book.createdAt),
            ),
            if (isOwner)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info, color: AppTheme.secondaryColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is one of your listings. You can manage it from the My Listings tab.',
                          style: TextStyle(color: AppTheme.secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isOwner || swapProvider.isLoading
                ? null
                : () => _handleSwapRequest(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: swapProvider.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isOwner ? 'This Is Your Book' : 'Request Swap'),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSwapRequest(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final swapProvider = context.read<SwapProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to request a swap.')),
      );
      return;
    }

    final alreadyPending = swapProvider.userSwaps.any((swap) {
      // Prevent duplicate pending requests for the same book.
      return swap.bookId == book.id && swap.status == SwapStatus.pending;
    });

    if (alreadyPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already have a pending swap for this book.')),
      );
      return;
    }

    try {
      final senderName = currentUser.displayName?.trim().isNotEmpty == true
          ? currentUser.displayName!.trim()
          : currentUser.email;

      await swapProvider.createSwap(
        SwapModel(
          id: '',
          senderUserId: currentUser.id,
          senderUserName: senderName,
          recipientUserId: book.userId,
          recipientUserName: book.userName,
          bookId: book.id,
          bookTitle: book.title,
          status: SwapStatus.pending,
          createdAt: DateTime.now(),
        ),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swap request sent!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create swap: $e')),
      );
    }
  }

  String _formatPostedTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }
    final minutes = difference.inMinutes.clamp(1, 59);
    return '$minutes minute${minutes == 1 ? '' : 's'} ago';
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.menu_book,
        size: 64,
        color: AppTheme.secondaryColor,
      ),
    );
  }
}
