// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api_services.dart';
import 'call_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String route = '/login_screen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Online Meetings'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image.asset(
                  'assets/meetings.jpg',
                  width: 300,
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    GoogleSignInAccount? user =
                        await ApiServices.signInWithGoogle(context);
                    if (user != null) {
                      Navigator.pushNamed(context, CallScreen.route,
                          arguments: {
                            'email': user.email,
                            'name': user.displayName,
                            'photoUrl': user.photoUrl,
                          });
                    }
                  },
                  child: const Text("Select Account"))
            ],
          ),
        ),
      ),
    );
  }
}
