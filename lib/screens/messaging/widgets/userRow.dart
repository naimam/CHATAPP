// ignore_for_file: use_key_in_widget_constructors, file_names

import 'package:chatapp/screens/home/contactProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/utils/helperFunctions.dart';
import 'package:chatapp/models/user.dart';
import 'package:chatapp/screens/messaging/newConversationScreen.dart';

class UserRow extends StatelessWidget {
  const UserRow({required this.uid, required this.contact});
  final String uid;
  final User contact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => createConversation(context),
      child: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const CircleAvatar(
                backgroundImage: AssetImage("assets/images/profilepic.jpg"),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ]),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => contactProfileScreen(
                              peerId: contact.id,
                              currentUserId: uid,
                            )));
              },
              child: const Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }

  void createConversation(BuildContext context) {
    String convoID = HelperFunctions.getConvoID(uid, contact.id);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => NewConversationScreen(
            uid: uid, contact: contact, convoID: convoID)));
  }
}
