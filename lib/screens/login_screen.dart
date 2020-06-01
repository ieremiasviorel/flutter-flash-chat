import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/long_button.dart';
import 'package:flash_chat/models/user_profile.dart';
import 'package:flash_chat/screens/main_screen.dart';
import 'package:flash_chat/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../constants.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'loginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _store = Firestore.instance;

  String email;
  String emailValidationText;

  String password;
  String passwordValidationText;

  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: ModalProgressHUD(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: emailInputOnChange,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your email',
                    errorText: emailValidationText),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: passwordInputOnChange,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password',
                    errorText: passwordValidationText),
              ),
              SizedBox(
                height: 24.0,
              ),
              LongButton(
                text: 'Log In',
                onTap: onLogInPress,
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
        ),
        inAsyncCall: showSpinner,
      ),
    );
  }

  void emailInputOnChange(String emailValue) {
    email = emailValue.trim();
    setState(() {
      emailValidationText = null;
    });
  }

  void passwordInputOnChange(String passwordValue) {
    password = passwordValue.trim();
    setState(() {
      passwordValidationText = null;
    });
  }

  String validateEmail(String email) {
    final emailRegEx = RegExp(
        r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    if (email == null || email.isEmpty) {
      return 'Email cannot be empty';
    } else if (!emailRegEx.hasMatch(email)) {
      return 'Email is not valid';
    } else {
      return null;
    }
  }

  String validatePassword(String password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 8) {
      return 'Password is too short';
    } else {
      return null;
    }
  }

  bool validateInputs() {
    String emailValidation = validateEmail(email);
    String passwordValidation = validatePassword(password);

    if (emailValidation != null || passwordValidation != null) {
      emailValidationText = emailValidation;
      passwordValidationText = passwordValidation;
      return false;
    } else {
      return true;
    }
  }

  void displaySpinner() {
    setState(() {
      showSpinner = true;
    });
  }

  void hideSpinner() {
    setState(() {
      showSpinner = false;
    });
  }

  void onLogInPress() async {
    try {
      displaySpinner();

      bool areInputsValid = validateInputs();

      if (!areInputsValid) {
        hideSpinner();
        return;
      }

      final authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      hideSpinner();

      if (authResult != null) {
        handleNavigationAfterAuth();
      }
    } catch (e) {
      handleAuthException(e);
    }
  }

  void handleAuthException(Exception e) {
    print(e);
    if (e is PlatformException) {
      String exceptionCode = e.code;
      if (exceptionCode == 'ERROR_USER_NOT_FOUND') {
        setState(() {
          emailValidationText = 'User does not exist';
        });
      } else if (exceptionCode == 'ERROR_WRONG_PASSWORD') {
        setState(() {
          passwordValidationText = 'Wrong user password';
        });
      }
    }
    hideSpinner();
  }

  void handleNavigationAfterAuth() async {
    UserProfile userProfile = await getUserProfile(email);

    if (userProfile != null) {
      Navigator.pushNamed(context, MainScreen.routeName);
    } else {
      Navigator.pushNamed(context, ProfileScreen.routeName);
    }
  }

  Future<UserProfile> getUserProfile(String email) {
    return _store
        .collection('profiles')
        .document(email)
        .get()
        .then((userProfileDocument) => userProfileDocument.data)
        .then((userProfileJson) => userProfileJson != null
            ? UserProfile.fromJson(userProfileJson)
            : null);
  }
}
