import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Logout extends StatelessWidget {
  const Logout({super.key});


  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth=FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Logout Screen'
        ),
      ),
      body: Center(child: TextButton(
        onPressed: ()async{
          await _auth.signOut();
        },
        child: const Text('Sign out',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),),
      )),
    );
  }
}
