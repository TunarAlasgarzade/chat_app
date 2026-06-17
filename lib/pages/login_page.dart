import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  // email and pw text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // tap to go to register
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  // login method
  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();

    // try login
    try {
      await authService.signInWithEmailPassword(_emailController.text, _pwController.text,);
    }

    // cacth any errors
    catch (e) {
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: const Text("Wrong email or password!", style: TextStyle(color: Colors.red),),
        )
      );
    }
  }

  // show reset password dialog
  void _showResetPasswordDialog(BuildContext context) async {
    // reset pw
    final TextEditingController resetEmailController = TextEditingController();
    
    // auth service
    final authService = AuthService();

    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Reset Password"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyTextField(
            controller: resetEmailController,
            hintText: "Email",
            obscureText: false,
          ),

          SizedBox(height: 20),
          
          Text("INFO: You will be sent a password reset link, from there you can reset it. If you don't receive the reset link, check your spam folder, it might be there.")
        ],
      ),
      actions: [
        TextButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text("Cancel")),
        TextButton(onPressed: () async {
          if (resetEmailController.text.contains("@") && resetEmailController.text.contains(".")) { 
            Navigator.pop(context);
            await authService.resetPw(resetEmailController.text.trim());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please use a real email")));
          }
        }, child: Text("Send Reset Link"))
      ],
    ));
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
              "Welcome back, you've been missed!",
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

            // forgot pw
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _showResetPasswordDialog(context),
                  child: Text(
                    "Forgot Password?", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary
                      )
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
        
            // login button
            MyButton(
              text: "Login",
              onTap: () => login(context),
            ),
        
            const SizedBox(height: 25),

            // register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member? ",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Register now!", 
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