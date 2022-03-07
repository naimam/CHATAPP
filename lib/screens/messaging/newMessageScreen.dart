import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/models/user.dart';
import 'package:chatapp/screens/messaging/widgets/userRow.dart';

class NewMessageScreen extends StatelessWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth.User user = Provider.of<auth.User>(context);
    final List<User> userDirectory = Provider.of<List<User>>(context);

    TextEditingController editingController = TextEditingController();
    List<Widget> getListViewItems(List<User> userDirectory, auth.User user) {
      final List<Widget> list = <Widget>[];
      for (User contact in userDirectory) {
        if (contact.id != user.uid) {
          list.add(UserRow(uid: user.uid, contact: contact));
          list.add(const Divider(thickness: 1.0));
        }
      }
      return list;
    }

    var userList = getListViewItems(userDirectory, user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Directory'),
      ),
      body: user != null && userDirectory != null
          ? Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editingController,
                      decoration: const InputDecoration(
                        hintText: 'Search for a user',
                      ),
                    ),
                  ),
                  Expanded(
                      child: ListView(
                          shrinkWrap: true,
                          children: userList
                              .where((element) => element
                                  .toString()
                                  .toLowerCase()
                                  .contains(
                                      editingController.text.toLowerCase()))
                              .toList())),
                ],
              ),
            )
          : const Text("No users found"),
    );
  }
}
