import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/models/chat_model.dart';
import '../../domain/models/swap_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/swap_provider.dart';
import 'chat_detail_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer3<ChatProvider, SwapProvider, AuthProvider>(
        builder: (context, chatProvider, swapProvider, authProvider, child) {
          final currentUserId = authProvider.currentUser?.id;
          final userSwaps = swapProvider.userSwaps;
          final chatThreads = chatProvider.chatThreads;

          if (userSwaps.isEmpty && chatThreads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppTheme.lightTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No swaps or chats yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTextColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send a swap request or accept one to start a conversation.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTextColor,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (userSwaps.isNotEmpty) ...[
                Text(
                  'My Offers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...userSwaps.map(
                  (swap) => _MyOfferCard(swap: swap),
                ),
                const SizedBox(height: 24),
              ],
              if (chatThreads.isNotEmpty) ...[
                Text(
                  'Chats',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...chatThreads.map(
                  (thread) => _ChatThreadCard(
                    thread: thread,
                    currentUserId: currentUserId,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MyOfferCard extends StatelessWidget {
  final SwapModel swap;

  const _MyOfferCard({required this.swap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(swap.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            swap.bookTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.swap_horiz, size: 16, color: AppTheme.lightTextColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Offered to ${swap.recipientUserName}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.lightTextColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  swap.status.displayName,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _timeAgo(swap.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppTheme.lightTextColor),
              ),
            ],
          ),
          if (swap.status == SwapStatus.pending)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_outlined,
                        size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Waiting for the owner to respond. The listing now lives in My Offers.',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

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

class _ChatThreadCard extends StatelessWidget {
  final ChatThread thread;
  final String? currentUserId;

  const _ChatThreadCard({required this.thread, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final otherName = _otherParticipantName();
    final lastMessage = thread.lastMessage ?? 'No messages yet';
  final timeLabel = thread.lastMessageAt != null
    ? _MyOfferCard._timeAgo(thread.lastMessageAt!)
        : 'Just now';
    final unreadCount = currentUserId != null
        ? thread.unreadCounts[currentUserId!] ?? 0
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatDetailPage(thread: thread),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.accentColor.withValues(alpha: 0.2),
                      child: Text(
                        otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              otherName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppTheme.lightTextColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.lightTextColor),
                      ),
                      if (unreadCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '$unreadCount unread message${unreadCount == 1 ? '' : 's'}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppTheme.errorColor),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _otherParticipantName() {
    if (currentUserId == thread.userId1) {
      return thread.userId2Name;
    }
    if (currentUserId == thread.userId2) {
      return thread.userId1Name;
    }
    return thread.userId2Name;
  }
}
