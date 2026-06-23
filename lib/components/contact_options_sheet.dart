import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class ContactOptionsSheet extends StatelessWidget {
  final Map<String, dynamic> userData;
  
  ContactOptionsSheet({super.key, required this.userData});
  final ChatService _chatService = ChatService();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Change Name"),
            onTap: () {
              _nameController.text = userData["contactName"] ?? "";
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Change contact name"),
                  content: MyTextField(
                    hintText: "New Name", 
                    obscureText: false, 
                    controller: _nameController,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(onPressed: () {
                      if (_nameController.text.trim().isEmpty) return;
                        _chatService.updateContact(userData["id"], _nameController.text.trim());
                        Navigator.pop(context);
                    }, child: const Text("Change name")),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.orange),
            title: const Text("Block Contact", style: TextStyle(color: Colors.orange)),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                  title: Text("Block contact?"),
                  content: Text("Are you sure you want to block the contact? If you block this contact, you can unblock them from Settings > Blocked Users."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                    TextButton(onPressed: () async {
                      Navigator.pop(context);
                      _chatService.blockUser(userData["id"]);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Contact blocked.")));
                    }, child: const Text("Yes"))
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete Contact", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                  title: Text("Delete contact?"),
                  content: Text("Are you sure you want to delete the contact?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                    TextButton(onPressed: () async {
                      Navigator.pop(context);
                      _chatService.deleteContact(userData["id"]);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Contact deleted.")));
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