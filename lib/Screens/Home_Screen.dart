// ignore_for_file: file_names

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dashchat/Screens/Login_Screen.dart';

class HomeScreen extends StatefulWidget {
  final String? user;
  const HomeScreen({Key? key, this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

final CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('users');

_signOut() async {
  await _firebaseAuth.signOut();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Chat Screen"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
          children: [
            SizedBox(
              height: 40,
              child: StreamBuilder(
                stream: collectionReference.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    UserModel userdata = UserModel(
                      uid: snapshot.data!.docs[0].get('uid'),
                      email: snapshot.data!.docs[0].get('email'),
                    );
                    return Column(
                      children: snapshot.data!.docs.map((document) {
                        return SizedBox(
                          child: Column(children: [
                            Center(
                              child: Text(userdata.email.toString()),
                            ),
                            Center(
                              child: Text(userdata.uid.toString()),
                            )
                          ]),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
