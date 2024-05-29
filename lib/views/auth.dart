import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:reminderapp/views/home_page.dart';
import 'package:reminderapp/views/main_screen.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
          );
        }
        return MainScreen();
      },
    );
  }
}
