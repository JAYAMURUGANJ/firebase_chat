// ignore_for_file: file_names, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/services/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dashchat/Screens/Login_Screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  final String? email;
  const ChatScreen({Key? key, this.email}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

final CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('messages');

final TextEditingController _textEditingController = TextEditingController();

_signOut() async {
  await _firebaseAuth.signOut();
}

class _ChatScreenState extends State<ChatScreen> {
  late FirebaseMessaging _firebaseMessaging;
  _registerOnFirebase() {
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  @override
  void initState() {
    _firebaseMessaging = FirebaseMessaging.instance;
    _registerOnFirebase();
    getMessage();
    super.initState();
  }

  void getMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['type'] == 'chat') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              email: message.data['email'],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.email ?? 'Chat Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              child: StreamBuilder<QuerySnapshot>(
                  stream: collectionReference
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot document =
                            snapshot.data!.docs[index];
                        return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            child: widget.email == document['email']
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              document['email'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: Text(
                                                document['message'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 5,
                                          right: 10,
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.green,
                                          child: Text(
                                            document['email']
                                                    ?.substring(0, 1) ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 5,
                                          right: 10,
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.amber,
                                          child: Text(
                                            document['email']
                                                    ?.substring(0, 1) ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              document['email'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: Text(
                                                document['message'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ));
                      },
                    );
                  }),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          controller: _textEditingController,
                          decoration: const InputDecoration(
                              hintText: "Write message...",
                              hintStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green, size: 30.0),
                  onPressed: () {
                    collectionReference.add({
                      'email': widget.email,
                      'message': _textEditingController.text,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    sendNotification(
                        _textEditingController.text, widget.email.toString());
                    _textEditingController.clear();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}



      // body: StreamBuilder<QuerySnapshot>(
      //   stream: collectionReference.snapshots(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //     return ListView.builder(
      //       itemCount: snapshot.data!.docs.length,
      //       itemBuilder: (context, index) {
      //         final DocumentSnapshot document = snapshot.data!.docs[index];
      //         final UserModel user = UserModel.fromMap(document.data());
      //         // ignore: unrelated_type_equality_checks
      //         return user.email != widget.email
      //             ? ListTile(
      //                 title: Text(user.email.toString()),
      //                 subtitle: Text(user.uid.toString()),
      //               )
      //             : Container();
      //       },
      //     );
      //   },
      // ),
