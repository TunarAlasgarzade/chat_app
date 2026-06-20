import 'package:chat_app/components/unread_count.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final void Function()? onMoreTap;
  final int unreadCount;

  const UserTile({
    super.key, 
    required this.text, 
    required this.onTap,
    this.onMoreTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            // icon
            const Icon(Icons.person),

            const SizedBox(width: 20),

            // user name
            Text(text),

            const Spacer(),

            // unread badge
            unreadCount > 0 ? UnreadCount(unreadCount: unreadCount) : SizedBox.shrink(),

            // more vert
            GestureDetector(
              onTap: onMoreTap,
              child: Icon(Icons.more_vert)
            )
          ],
        ),
      ),
    );
  }
}