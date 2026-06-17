import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void logout() {
    // get auth service
    final auth = AuthService();
    auth.signOut();
  }

  // reset pw
  void resetPassword(BuildContext context, String? email) async {
    final authService = AuthService();
    await authService.resetPw(email!);
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    // get user email

    final AuthService authService = AuthService();
    final String? userEmail = authService.getCurrentUser()?.email;

    return Column(
      children: [
        // reset pw ListTile
        ListTile(
          title: Text("Reset Password",),
          leading: Icon(Icons.lock_reset,),
          onTap: () => showDialog(
            context: context, 
            builder: (context) => AlertDialog(
              title: Text("Reset Password"),
              content: Text("A password reset link will be sent to your email address $userEmail. Are you sure?"),
              actions: [
                TextButton(onPressed: () {Navigator.pop(context);}, child: Text("Cancel")),
                TextButton(onPressed: () {resetPassword(context, userEmail);}, child: Text("Yes"))
              ],
            )
          ),
        ),

        // logout ListTile
        ListTile(
          title: const Text("L O G O U T", style: TextStyle(color: Color.fromARGB(255, 255, 17, 0)),),
          leading: Icon(Icons.logout, color: const Color.fromARGB(255, 255, 17, 0),),
          onTap: () => showDialog(
            context: context, 
            builder: (context) => AlertDialog(
              title: const Text("Logout"),
              content: const Text("Are you sure you want to log out?"),
              actions: [
                TextButton(onPressed: () {Navigator.pop(context);}, child: Text("No")),
                TextButton(onPressed: () {Navigator.pop(context); logout();}, child: Text("Yes")),
              ],
            ),
          ),
        ),
      ],
    );
  }
}