import 'package:chatapp/screens/auth/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late double userRating;
  late List<dynamic> userRatingUids;
  late double userRatingCount;
  late double userRatingAverage;

  late final _profileUrlController;
  late GlobalKey<FormState> _formKey;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _profileUrlController = TextEditingController();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final auth.User firebaseUser = Provider.of<auth.User>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: const Text(
          'Profile',
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                signOut(context);
              },
              child: const Icon(
                Icons.logout,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var userDocument = snapshot.data;
          userRating = userDocument!['rating'];
          userRatingUids = userDocument['ratingUids'] ?? [];
          userRatingCount = userRatingUids.length.toDouble();
          userRatingAverage =
              userRatingCount == 0 ? 0 : userRating / userRatingCount;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage('assets/images/profilepic.jpg'),
                  ),
                  const SizedBox(
                    width: 30.0,
                    height: 20.0,
                  ),
                  // bold text
                  Text(
                    userDocument['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(
                    width: 30.0,
                    height: 20.0,
                  ),
                  const Text(// normal text
                      "Your rating: "),
                  Text(
                    double.parse(userRatingAverage.toString())
                            .toStringAsFixed(2) +
                        '/5.0',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Text("Out of " + userRatingCount.toString() + " ratings."),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
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
