import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/models/book_model.dart';
import '../../domain/models/swap_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/swap_provider.dart';
import 'chat_detail_page.dart';

class SwapRequestsPage extends StatelessWidget {
  final BookModel book;

  const SwapRequestsPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final swapProvider = context.watch<SwapProvider>();
    final requests = swapProvider.receivedSwaps
        .where((swap) => swap.bookId == book.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap Requests'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: requests.isEmpty
          ? _EmptyState(bookTitle: book.title)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];
                return _SwapRequestCard(book: book, request: request);
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String bookTitle;

  const _EmptyState({required this.bookTitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swap_horiz, size: 48, color: AppTheme.lightTextColor),
            const SizedBox(height: 16),
            Text(
              'No swap requests for "$bookTitle" yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'When someone requests to swap, their details will show up here so you can accept or reject the offer.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.lightTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapRequestCard extends StatelessWidget {
  final BookModel book;
  final SwapModel request;

  const _SwapRequestCard({required this.book, required this.request});

  Color _statusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.accepted:
        return AppTheme.successColor;
      case SwapStatus.rejected:
        return AppTheme.errorColor;
      case SwapStatus.completed:
        return AppTheme.accentColor;
      case SwapStatus.pending:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final swapProvider = context.watch<SwapProvider>();
    final chatProvider = context.watch<ChatProvider>();

    final isProcessing = swapProvider.isLoading || chatProvider.isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.accentColor.withValues(alpha: 0.2),
                child: Text(
                  request.senderUserName.isNotEmpty
                      ? request.senderUserName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.senderUserName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requested ${_timeAgo(request.createdAt)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.lightTextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(request.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.status.displayName,
                  style: TextStyle(
                    color: _statusColor(request.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (request.status == SwapStatus.pending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            await _handleDecision(
                              context,
                              status: SwapStatus.rejected,
                              successMessage:
                                  'Swap request declined. The requester will be notified.',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            await _handleDecision(
                              context,
                              status: SwapStatus.accepted,
                              successMessage:
                                  'Swap accepted! A chat thread has been created so you can plan the exchange.',
                              createChat: true,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            )
          else ...[
            Text(
              request.status == SwapStatus.accepted
                  ? 'This swap was accepted. Head to Chats to coordinate the exchange.'
                  : request.status == SwapStatus.rejected
                      ? 'You declined this swap.'
                      : 'This swap is marked as completed.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.lightTextColor),
            ),
            if (request.status == SwapStatus.accepted)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _openChat(context),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Open Chat'),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleDecision(
    BuildContext context, {
    required SwapStatus status,
    required String successMessage,
    bool createChat = false,
  }) async {
    final swapProvider = context.read<SwapProvider>();
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    try {
      await swapProvider.updateSwapStatus(request.id, status);

      if (createChat) {
        final owner = authProvider.currentUser;
        if (owner != null) {
          await chatProvider.getOrCreateChatThread(
            userId1: owner.id,
            userId1Name: owner.displayName ?? owner.email,
            userId2: request.senderUserId,
            userId2Name: request.senderUserName,
            swapId: request.id,
          );
        }
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update swap: $e')),
      );
    }
  }

  Future<void> _openChat(BuildContext context) async {
    final chatProvider = context.read<ChatProvider>();
    final threads = chatProvider.chatThreads;

    if (threads.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat thread not ready yet. Try again in a moment.')),
        );
      }
      return;
    }
    final thread = threads.firstWhere(
      (t) => t.swapId == request.id,
      orElse: () => threads.firstWhere(
        (t) => t.participants.contains(request.senderUserId),
        orElse: () => threads.first,
      ),
    );

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(thread: thread),
      ),
    );
  }

  static String _timeAgo(DateTime createdAt) {
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
