import 'package:chat_app/components/add_contact_dialog.dart';
import 'package:chat_app/components/contact_options_sheet.dart';
import 'package:chat_app/components/my_bottomnav.dart';
import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/pages/settings_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  // chat & auth service
  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? "Chats" : _selectedIndex == 1 ? "Profile" : "Settings"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: _selectedIndex == 0 ? [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddContactDialog(context)
          )
        ] : null
      ),
      body: _selectedIndex == 0 
      ? _buildUserList() 
      : _selectedIndex == 1 
        ? ProfilePage() 
        : const SettingsPage(),
      bottomNavigationBar: MyBottomNav(
      currentIndex: _selectedIndex,
      onTap: (index) {
          setState(() {
          _selectedIndex = index;
        });
      },
    ),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getContactsStream(), 
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading..
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No contacts added yet."));
        }

        // return list view
        return ListView(
          children: snapshot.data!
          .map<Widget>((userData) => _buildUserListItem(userData, context))
          .toList(),
        );
      },
    );
  }

  // build invidual list tile for user 
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return StreamBuilder<bool>(
        stream: _chatService.isUserBlocked(userData["id"]),
        builder: (context, blockedSnapshot) {
          bool isBlocked = blockedSnapshot.data ?? false;
          if (isBlocked) return Container();
          return StreamBuilder<int>(
            stream: _chatService.getUnreadCountStream(userData["id"]),
            builder: (context, snapshot) {
              int unreadCount = snapshot.data ?? 0;
              return UserTile(
                text: userData["contactName"] ?? userData["email"],
                unreadCount: unreadCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverEmail: userData["email"],
                        receiverID: userData["id"],
                        receiverName: userData["contactName"] ?? userData["email"],
                      ),
                    ),
                  );
                },
                onMoreTap: () => _showContactOptions(context, userData),
              );
            },
          );
        },
      );
    } else {
      return Container();
    }
  }

  void _showAddContactDialog(BuildContext context) {
    showDialog(
      context: context, 
      builder: (context) => const AddContactDialog()
    );
  }

  void _showContactOptions(BuildContext context, Map<String, dynamic> userData) {
  showModalBottomSheet(
    context: context,
    builder: (context) => ContactOptionsSheet(userData: userData),
  );
}
}
