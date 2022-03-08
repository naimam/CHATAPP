import 'package:chatapp/models/user.dart';
import 'package:chatapp/screens/messaging/newConversationScreen.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/utils/helperFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class contactProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String peerId;

  const contactProfileScreen(
      {Key? key, required this.peerId, required this.currentUserId})
      : super(key: key);

  @override
  State<contactProfileScreen> createState() => _contactProfileScreenState();
}

class _contactProfileScreenState extends State<contactProfileScreen> {
  late String peerId;
  late String peerName;
  late double peerRating;
  late List<dynamic> peerRatingUids;
  late double peerRatingCount;
  late double peerRatingAverage;
  late User contact;
  late String currentUserId;
  late bool isRated;

  late final _ratingController;
  late double _userRating;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _ratingController = TextEditingController();
    _userRating = 0.0;
    peerId = widget.peerId;
    currentUserId = widget.currentUserId;
    isRated = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: const Text('Profile'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(peerId)
            .snapshots(),
        builder: (context, snapshot) {
          var peerDocument = snapshot.data;
          contact = User.fromMap(peerDocument!.data() as Map<String, dynamic>);
          peerName = peerDocument['name'] ?? 'No name';
          peerRating = peerDocument['rating'];
          peerRatingUids = peerDocument['ratingUids'] ?? [];
          isRated = peerRatingUids.contains(currentUserId);
          peerRatingCount = peerRatingUids.length.toDouble();
          peerRatingAverage =
              peerRatingCount == 0 ? 0 : peerRating / peerRatingCount;

          return Center(
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
                  peerName,
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
                    "Rating: "),
                Text(
                  double.parse(peerRatingAverage.toString())
                          .toStringAsFixed(2) +
                      '/5.0',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Text("Out of " + peerRatingCount.toString() + " ratings."),
                const SizedBox(
                  width: 30.0,
                  height: 20.0,
                ),

                isRated
                    ? const Text(
                        "You have already rated this user.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.red,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          showRatingDialog(
                              context, peerId, peerName, widget.currentUserId);
                        },
                        child: const Text('Rate'),
                      ),

                ElevatedButton.icon(
                  onPressed: () {
                    createConversation(context);
                  },
                  icon: const Icon(Icons.chat_bubble),
                  label: const Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void createConversation(BuildContext context) {
    String convoID = HelperFunctions.getConvoID(currentUserId, peerId);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => NewConversationScreen(
            uid: currentUserId, contact: contact, convoID: convoID)));
  }

  void showRatingDialog(
      BuildContext context, String peerId, String peerName, String userId) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: ((context, setState) {
              return AlertDialog(
                title: Text('Rate:' + peerName),
                content: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _ratingController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                double? doubleValue = double.tryParse(value!);

                                if (value.isEmpty ||
                                    doubleValue == null ||
                                    doubleValue > 5 ||
                                    doubleValue < 0) {
                                  return 'Enter a number between 0 and 5';
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                suffixIcon: MaterialButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _userRating = double.parse(
                                            _ratingController.text);
                                        addRating(_userRating, userId, peerId);
                                      });
                                    }
                                  },
                                  child: const Text('SUBMIT'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(),
                      ]),
                ),
              );
            }),
          );
        });
  }

  void addRating(double rating, String userId, String peerId) async {
    try {
      Database.addRating(rating, userId, peerId);

      Navigator.of(context, rootNavigator: true).pop('dialog');
    } catch (e) {
      print(e);
    }
  }
}
