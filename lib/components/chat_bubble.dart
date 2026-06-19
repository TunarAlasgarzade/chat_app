import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final bool isRead;

  const ChatBubble({
    super.key, 
    required this.message, 
    required this.isCurrentUser,
    required this.isRead
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12)
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(child: Text(message, style: TextStyle(color: Colors.white))),
          if (isCurrentUser) ...[
            SizedBox(width: 6),
            Icon(
              isRead ? Icons.done_all : Icons.done,
              size: 14,
              color: isRead ? Colors.blue : Colors.white70,
            ),
          ]
        ],
      ),
    );
  }
}