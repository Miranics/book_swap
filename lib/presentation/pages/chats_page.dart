import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble,
              size: 64,
              color: AppTheme.lightTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No active chats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a swap to begin chatting',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
