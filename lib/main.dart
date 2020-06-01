import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/contacts_screen.dart';
import 'package:flash_chat/screens/invitations_screen.dart';
import 'package:flash_chat/screens/main_screen.dart';
import 'package:flash_chat/screens/profile_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/welcome_screen.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (context) => WelcomeScreen(),
        RegistrationScreen.routeName: (context) => RegistrationScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        MainScreen.routeName: (context) => MainScreen(),
        ContactsScreen.routeName: (context) => ContactsScreen(),
        InvitationsScreen.routeName: (context) => InvitationsScreen(),
        ChatScreen.routeName: (context) => ChatScreen()
      },
    );
  }
}
