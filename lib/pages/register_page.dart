import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  // email and pw text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confrimPwController = TextEditingController();

  // tap to go to register
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  // register method
  void register(BuildContext context) {
    // get auth service
    final auth = AuthService();

    // passwords match -> create user
    if (_pwController.text == _confrimPwController.text) {
      try {
        auth.signUpWithEmailPassword(
      _emailController.text, 
      _pwController.text,
    );
      } catch (e) {
        showDialog(
          context: context, 
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          )
        );
      }
    }
    // passwords dont match -> tell user to fix

    else {
      showDialog(
          context: context, 
          builder: (context) => const AlertDialog(
            title: Text("Passwords don't match!"),
          )
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
        
            const SizedBox(height: 50),

            // welcome back massage
            Text(
              "Let's create an account for you",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16
              ),
            ),
        
            const SizedBox(height: 25),

            // email textfield
            MyTextField(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),
        
            const SizedBox(height: 10),

            // pw textfield
            MyTextField(
              hintText: "Password",
              obscureText: true,
              controller: _pwController,
            ),

            const SizedBox(height: 10),

            // confrim pw textfield
            MyTextField(
              hintText: "Confrim password",
              obscureText: true,
              controller: _confrimPwController,
            ),

            const SizedBox(height: 25),
        
            // login button
            MyButton(
              text: "Register",
              onTap: () => register(context),
            ),
        
            const SizedBox(height: 25),

            // register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login now", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary
                    )
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}