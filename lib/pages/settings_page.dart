import 'package:chat_app/pages/appearance_page.dart';
import 'package:chat_app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'blocked_users_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppearancePage()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.all(Radius.circular(12))
              ),
              margin: const EdgeInsets.only(right: 15, left: 15, top: 15),
              padding:const EdgeInsets.all(27.6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // blocked users
                  const Text("Appearance"),
              
                  // arrow forward
                  Icon(Icons.arrow_forward)
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlockedUsersPage()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.all(Radius.circular(12))
              ),
              margin: const EdgeInsets.only(right: 15, left: 15, top: 15),
              padding:const EdgeInsets.all(27.6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // blocked users
                  const Text("Blocked Users"),
              
                  // arrow forward
                  Icon(Icons.arrow_forward)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}