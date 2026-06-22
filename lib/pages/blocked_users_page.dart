import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});
  
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final String currentUid = _authService.getCurrentUser()!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blocked Users"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getBlockedUsersStream(currentUid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text("Error");
          if (snapshot.connectionState == ConnectionState.waiting) return const Text("Loading..");
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No blocked users."));
          }
          return ListView(
            children: snapshot.data!
                .map((userData) => ListTile(
                      title: Text(userData["email"] ?? "Unknown"),
                      leading: const Icon(Icons.block),
                      onTap: () {
                        showDialog(
                          context: context, 
                          builder: (context) => AlertDialog(
                            title: Text("Unblock concact?"),
                            content: Text("Are you sure you want to unblock the contact?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                              TextButton(onPressed: () async {
                                Navigator.pop(context);
                                _chatService.unblockUser(userData["id"]);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Contact unblocked.")));
                              }, child: const Text("Yes"))
                            ],
                          ),
                        );
                      },
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}