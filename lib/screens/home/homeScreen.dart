import 'package:chatapp/providers/conversationProvider.dart';
import 'package:chatapp/screens/home/homeBuilder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/screens/auth/signin.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final User? firebaseUser = Provider.of<User?>(context);
    return (firebaseUser != null)
        ? ConversationProvider(user: firebaseUser)
        : SignIn();
  }
}
