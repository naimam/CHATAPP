import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/screens/signin.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? user = FirebaseAuth.instance.currentUser;

  TextEditingController textFieldController = TextEditingController();
  bool admin = false;
  String userFName = " ";
  String userLName = " ";
  String userRole = " ";
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  Future<void> ifUserAdmin() async {
    await users.doc(user?.uid).get().then((DocumentSnapshot document) {
      if (document.exists) {
        userRole = document['role'];
        admin = (userRole == 'admin');
        userFName = document['first_name'];
        if (userFName == " ") {
          userFName = user!.displayName.toString();
        }

        userLName = document['last_name'];
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    ifUserAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Welcome, " + userRole + " " + userFName),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                signOut(context);
              }),
        ],
      ),
      body: StreamBuilder(
        stream: posts.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text("No posts yet"),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: <Widget>[
                      Flexible(
                          child: Text(
                              document['message'] + "\n" + "Posted by ADMIN.",
                              style: const TextStyle(fontSize: 20))),
                    ]),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: admin == true
          ? FloatingActionButton(
              onPressed: () async {
                final postMessage = await openDialog();
                if (postMessage != null && postMessage.isNotEmpty) {
                  final register_date = DateTime.now().toString();
                  posts.doc().set({
                    'message': postMessage,
                    "register_date": register_date,
                  });
                }
              },
              tooltip: 'Add post',
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void signOut(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to log out?"),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const SignIn()));
                },
                child: const Text("Yes."),
              ),
            ],
          );
        });
  }

  Future<String?> openDialog() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Add post"),
            content: TextField(
              autofocus: true,
              controller: textFieldController,
              decoration: const InputDecoration(
                labelText: "Post",
                hintText: "Add post",
              ),
            ),
            actions: [
              TextButton(
                  onPressed: submitPost, child: const Text("Post message!")),
              IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancel',
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          ));

  void submitPost() {
    Navigator.of(context).pop(textFieldController.text);
    textFieldController.clear();
  }
}
