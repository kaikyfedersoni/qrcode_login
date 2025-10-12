import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import 'widgets/google_login_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Login IFSP APP')),
      body: Center(
        child: GoogleLoginButton(
          onPressed: () => controller.signInWithGoogle(context),
        ),
      ),
    );
  }
}
