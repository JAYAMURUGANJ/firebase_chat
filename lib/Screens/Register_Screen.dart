// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dashchat/Component/button.dart';

import '../constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                          const Hero(
                            tag: '1',
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              email = value.toString().trim();
                            },
                            validator: (value) =>
                                (value!.isEmpty) ? ' Please enter email' : null,
                            textAlign: TextAlign.center,
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Enter Your Email',
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
                                hintText: 'Choose a Password',
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                )),
                          ),
                          const SizedBox(height: 80),
                          LoginSignupButton(
                            title: 'Register',
                            ontapp: () async {
                              if (formkey.currentState!.validate()) {
                                setState(() {
                                  isloading = true;
                                });
                                try {
                                  await _auth
                                      .createUserWithEmailAndPassword(
                                          email: email, password: password)
                                      .then((value) =>
                                          collectionReference.doc(email).set({
                                            'uid': value.user!.uid,
                                            'email': email,
                                            'createdAt': value
                                                .user!.metadata.creationTime!
                                                .toIso8601String(),
                                            'lastSignInTime': value
                                                .user!.metadata.lastSignInTime!
                                                .toIso8601String(),
                                            'updatedAt': DateTime.now()
                                                .toIso8601String(),
                                          }));

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.blueGrey,
                                      content: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                            'Sucessfully Register.You Can Login Now'),
                                      ),
                                      duration: Duration(seconds: 5),
                                    ),
                                  );
                                  Navigator.of(context).pop();

                                  setState(() {
                                    isloading = false;
                                  });
                                } on FirebaseAuthException catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text(
                                          ' Ops! Registration Failed'),
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
                                }
                                setState(() {
                                  isloading = false;
                                });
                              }
                            },
                          ),
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
