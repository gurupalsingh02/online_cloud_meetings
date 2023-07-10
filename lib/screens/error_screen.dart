import 'package:flutter/material.dart';

import 'login_screen.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("this page does not exist"),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.route);
                },
                child: const Text("go to Home"))
          ],
        ),
      ),
    );
  }
}
