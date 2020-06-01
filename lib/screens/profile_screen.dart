import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/long_button.dart';
import 'package:flash_chat/models/user_profile.dart';
import 'package:flash_chat/screens/main_screen.dart';
import 'package:flash_chat/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../constants.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = 'profileScreen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService.instance;

  String username;
  String usernameValidationText;

  String firstName;
  String firstNameValidationText;

  String lastName;
  String lastNameValidationText;

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
                  'Let\'s get started on your profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                onChanged: usernameInputOnChange,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your username',
                    errorText: usernameValidationText),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                onChanged: firstNameInputOnChange,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your first name',
                    errorText: firstNameValidationText),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                onChanged: lastNameInputOnChange,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your last name',
                    errorText: lastNameValidationText),
              ),
              SizedBox(
                height: 24.0,
              ),
              LongButton(
                text: 'Submit',
                onTap: onSubmitPress,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
        inAsyncCall: showSpinner,
      ),
    );
  }

  void usernameInputOnChange(String usernameValue) {
    username = usernameValue.trim();
    setState(() {
      usernameValidationText = null;
    });
  }

  void firstNameInputOnChange(String firstNameValue) {
    firstName = firstNameValue.trim();
    setState(() {
      firstNameValidationText = null;
    });
  }

  void lastNameInputOnChange(String lastNameValue) {
    lastName = lastNameValue.trim();
    setState(() {
      lastNameValidationText = null;
    });
  }

  String validateUsername(String username) {
    if (username == null || username.isEmpty) {
      return 'Username cannot be empty';
    } else {
      return null;
    }
  }

  String validateFirstName(String firstName) {
    if (firstName == null || firstName.isEmpty) {
      return 'First name cannot be empty';
    } else {
      return null;
    }
  }

  String validateLastName(String lastName) {
    if (lastName == null || lastName.isEmpty) {
      return 'Last name cannot be empty';
    } else {
      return null;
    }
  }

  bool validateInputs() {
    String usernameValidation = validateUsername(username);
    String firstNameValidation = validateFirstName(firstName);
    String lastNameValidation = validateLastName(lastName);

    if (usernameValidation != null ||
        firstNameValidation != null ||
        lastNameValidation != null) {
      usernameValidationText = usernameValidation;
      firstNameValidationText = firstNameValidation;
      lastNameValidationText = lastNameValidation;
      return false;
    } else {
      return true;
    }
  }

  void onSubmitPress() async {
    try {
      displaySpinner();

      bool areInputsValid = validateInputs();

      if (!areInputsValid) {
        hideSpinner();
        return;
      }

      FirebaseUser currentUser = await _userService.getCurrentUser();

      await _userService.setUserProfile(
          UserProfile(currentUser.email, username, firstName, lastName));

      hideSpinner();

      Navigator.pushNamed(context, MainScreen.routeName);
    } catch (e) {
      print(e);
      hideSpinner();
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
}
