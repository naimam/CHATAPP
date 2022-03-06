import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/models/user.dart';
import 'package:chatapp/screens/messaging/widgets/userRow.dart';

class NewMessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth.User user = Provider.of<auth.User>(context);
    final List<User> userDirectory = Provider.of<List<User>>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Select Contact')),
      body: user != null && userDirectory != null
          ? ListView(
              shrinkWrap: true, children: getListViewItems(userDirectory, user))
          : Container(),
    );
  }

  List<Widget> getListViewItems(List<User> userDirectory, auth.User user) {
    final List<Widget> list = <Widget>[];
    for (User contact in userDirectory) {
      if (contact.id != user.uid) {
        list.add(UserRow(uid: user.uid, contact: contact));
        list.add(Divider(thickness: 1.0));
      }
    }
    return list;
  }
}
