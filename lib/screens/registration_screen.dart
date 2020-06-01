import 'package:flash_chat/components/long_button.dart';
import 'package:flash_chat/screens/profile_screen.dart';
import 'package:flash_chat/services/user_service.dart';
import 'package:flash_chat/utils/input_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../constants.dart';

class RegistrationScreen extends StatefulWidget {
  static const String routeName = 'registrationScreen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final UserService _userService = UserService.instance;

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
                  'Glad you want to join us',
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
                text: 'Register',
                onTap: onRegisterPress,
                color: Colors.blueAccent,
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

  void onRegisterPress() async {
    try {
      displaySpinner();

      bool areInputsValid = validateInputs();

      if (!areInputsValid) {
        hideSpinner();
        return;
      }

      final registerResult = await _userService.register(email, password);

      hideSpinner();

      if (registerResult != null) {
        Navigator.pushNamed(context, ProfileScreen.routeName);
      }
    } catch (e) {
      print(e);
      handleRegisterException(e);
    }
  }

  void handleRegisterException(Exception e) {
    print(e);
    if (e is PlatformException) {
      String exceptionCode = e.code;
      if (exceptionCode == 'ERROR_EMAIL_ALREADY_IN_USE') {
        setState(() {
          emailValidationText = 'Email is already linked to another account';
        });
      }
    }
    hideSpinner();
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
