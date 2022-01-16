// ignore_for_file: avoid_print, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dashchat/Component/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'Chat_screen.dart';
import 'Register_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool isloading = false;

  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: formkey,
              child: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 120),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sign In",
                            style: TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              email = value;
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter Email";
                              }
                            },
                            textAlign: TextAlign.center,
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Email',
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter Password";
                              }
                            },
                            onChanged: (value) {
                              password = value;
                            },
                            textAlign: TextAlign.center,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Password',
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                )),
                          ),
                          const SizedBox(height: 80),
                          LoginSignupButton(
                            title: 'Login',
                            ontapp: () async {
                              if (formkey.currentState!.validate()) {
                                setState(() {
                                  isloading = true;
                                });
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                try {
                                  await _auth
                                      .signInWithEmailAndPassword(
                                          email: email, password: password)
                                      .then((value) => collectionReference
                                              .doc(email)
                                              .update({
                                            'lastSignInTime': value
                                                .user!.metadata.lastSignInTime!
                                                .toIso8601String()
                                          }));

                                  prefs.setString('email', email);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        email: email,
                                      ),
                                    ),
                                  );

                                  setState(() {
                                    isloading = false;
                                  });
                                } on FirebaseAuthException catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Ops! Login Failed"),
                                      content: Text('${e.message}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text('Okay'),
                                        )
                                      ],
                                    ),
                                  );
                                  //print(e);
                                }
                                setState(() {
                                  isloading = false;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            child: Row(
                              children: const [
                                Text(
                                  "Don't have an Account ?",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black87),
                                ),
                                SizedBox(width: 10),
                                Hero(
                                  tag: '1',
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
