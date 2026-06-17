import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class AddContactDialog extends StatelessWidget {
  const AddContactDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final TextEditingController contactNameController = TextEditingController();
    final TextEditingController contactEmailController = TextEditingController();

    return AlertDialog(
      title: const Text("Add New Contact"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyTextField(
            hintText: "Contact Name", 
            obscureText: false, 
            controller: contactNameController
          ),
          const SizedBox(height: 10),
          MyTextField(
            hintText: "Contact Email", 
            obscureText: false, 
            controller: contactEmailController
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {Navigator.pop(context);}, 
          child: Text("Cancel")
        ),
        TextButton(
          onPressed: () async {
            try { 
              await chatService.addContact(
              contactEmailController.text.trim(), 
              contactNameController.text.trim(),
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Contact added successfully!"))
              );
            } catch (e) {
              if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
                );
              }
          },
          child: Text("Add Contact")
        ),
      ],
    );
  }
}