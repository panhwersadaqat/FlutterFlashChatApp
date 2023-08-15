import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:flashchat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:colorful_circular_progress_indicator/colorful_circular_progress_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {

  static const String id = "login_screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool _isLoggingIn = false; // Track whether login is in progress

  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _overlayEntry = OverlayEntry(builder: (context) => _buildOverlay());
  }

  @override
  void dispose() {
    _overlayEntry.remove();
    super.dispose();
  }

  Widget _buildOverlay() {
    if (_isLoggingIn) {
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  title: 'Log In',
                  color: Colors.blueAccent,
                  onPressed: () async {
                    try {
                      setState(() {
                        _isLoggingIn = true;
                      });

                      Overlay.of(context)?.insert(_overlayEntry);

                      final user = await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      if (user != null) {
                        Navigator.pushNamed(context, ChatScreen.id);
                      }
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "Invalid credentials",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                      print(e);
                    } finally {
                      setState(() {
                        _isLoggingIn = false;
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



