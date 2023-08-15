import 'package:colorful_circular_progress_indicator/colorful_circular_progress_indicator.dart';
import 'package:flashchat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:flashchat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';


class RegistrationScreen extends StatefulWidget {

  static const String id = "registration_screen";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  late String email;
  late String password;
  bool _isRegistering = false; // Track whether registration is in progress
  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _overlayEntry = OverlayEntry(builder: (context) => _buildOverlay());
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _overlayEntry.remove();
    super.dispose();
  }

  Widget _buildOverlay() {
    if (_isRegistering) {
      return const Center(
        child: ColorfulCircularProgressIndicator(
          colors: [Colors.blue, Colors.red, Colors.amber, Colors.green],
          strokeWidth: 5,
          indicatorHeight: 40,
          indicatorWidth: 40,
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                const SizedBox(height: 48.0),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                  style: TextStyle(color: Colors.black),
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  style: TextStyle(color: Colors.black),
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24.0),
                      RoundedButton(
                        title: 'Register',
                        color: Colors.blueAccent,
                        onPressed: () async {
                          try {
                            setState(() {
                              _isRegistering = true;
                            });

                            Overlay.of(context)?.insert(_overlayEntry);

                            final newUser = await _auth.createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            if (newUser != null) {
                              Fluttertoast.showToast(
                                msg: "Registration successful",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                              Navigator.pushNamed(context, ChatScreen.id);
                            }
                          } catch (e) {
                            print(e);
                          } finally {
                            setState(() {
                              _isRegistering = false;
                            });
                            _overlayEntry.remove();
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ),
          ),
        );
  }
}
