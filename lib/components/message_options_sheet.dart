import 'package:chat_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class MessageOptionsSheet extends StatelessWidget {
  final String receiverID;
  final String messageID;
  final ChatService _chatService = ChatService();
  
  MessageOptionsSheet({
    super.key, 
    required this.receiverID, 
    required this.messageID
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete Message", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                  title: Text("Delete message?"),
                  content: Text("Are you sure you want to delete the message?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                    TextButton(onPressed: () async {
                      Navigator.pop(context);
                      _chatService.deleteMessage(receiverID, messageID);
                      await ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message deleted.")));
                    }, child: const Text("Yes"))
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}