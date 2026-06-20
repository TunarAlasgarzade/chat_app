import 'package:flutter/material.dart';

class UnreadCount extends StatelessWidget {
  final int unreadCount;

  const UnreadCount({
    super.key,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.green, 
        shape: BoxShape.circle
      ),
      margin: EdgeInsets.only(right: 5),
      width: 23,
      height: 23,
      alignment: Alignment.center,
      child: Text(unreadCount.toString()),
    );
  }
}