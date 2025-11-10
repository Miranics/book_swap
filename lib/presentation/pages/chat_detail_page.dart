import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/models/chat_model.dart';
import '../../domain/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatThread thread;

  const ChatDetailPage({super.key, required this.thread});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().listenToMessages(widget.thread.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;

    final thread = chatProvider.chatThreads.firstWhere(
      (t) => t.id == widget.thread.id,
      orElse: () => widget.thread,
    );

    final messages = chatProvider.messages;
    final otherUserName = _otherParticipantName(thread, currentUser?.id);

    final unreadCount = currentUser != null
        ? thread.unreadCounts[currentUser.id] ?? 0
        : 0;

    if (currentUser != null && unreadCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context
            .read<ChatProvider>()
            .markThreadAsRead(threadId: thread.id, userId: currentUser.id);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _EmptyChatState(otherUserName: otherUserName)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMine = message.senderId == currentUser?.id;
                      return Align(
                        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMine
                                ? AppTheme.accentColor.withValues(alpha: 0.9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: isMine
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (!isMine)
                                Text(
                                  message.senderName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppTheme.primaryColor),
                                ),
                              if (!isMine) const SizedBox(height: 2),
                              Text(
                                message.message,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isMine ? AppTheme.primaryColor : AppTheme.textColor,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(message.timestamp),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: AppTheme.lightTextColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _ChatComposer(
            controller: _messageController,
            onSend: (value) => _handleSend(context, value, currentUser, thread),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend(
    BuildContext context,
    String message,
    UserModel? currentUser,
    ChatThread thread,
  ) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || currentUser == null) {
      return;
    }

    final chatProvider = context.read<ChatProvider>();
    final recipientId = currentUser.id == thread.userId1
        ? thread.userId2
        : thread.userId1;
    try {
      await chatProvider.sendMessage(
        threadId: thread.id,
        message: ChatMessage(
          id: '',
          senderId: currentUser.id,
          senderName: currentUser.displayName ?? currentUser.email,
          recipientId: recipientId,
          message: trimmed,
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
      _messageController.clear();
      await chatProvider.markThreadAsRead(
        threadId: thread.id,
        userId: currentUser.id,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  String _otherParticipantName(ChatThread thread, String? currentUserId) {
    if (currentUserId == thread.userId1) {
      return thread.userId2Name;
    }
    return thread.userId1Name;
  }

  static String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    }
    return '${timestamp.year}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}';
  }
}

class _ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  const _ChatComposer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: onSend,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => onSend(controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: AppTheme.primaryColor,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  final String otherUserName;

  const _EmptyChatState({required this.otherUserName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.lightTextColor),
          const SizedBox(height: 16),
          Text(
            'Say hi to $otherUserName!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start coordinating your swap here.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.lightTextColor),
          ),
        ],
      ),
    );
  }
}
