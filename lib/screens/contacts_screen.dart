import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/models/chat_screen_arguments.dart';
import 'package:flash_chat/models/user_invitation.dart';
import 'package:flash_chat/models/user_profile.dart';
import 'package:flash_chat/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  static const String routeName = 'contactsScreen';

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final UserService _userService = UserService.instance;

  UserProfile currentUser;
  List<UserProfile> userContacts;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getUserContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: ModalProgressHUD(
          child: userContacts != null
              ? userContacts.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: userContacts.length,
                      itemBuilder: (context, index) {
                        final userContact = userContacts[index];
                        return UserContactsList(
                            currentUser: currentUser, userContact: userContact);
                      })
                  : Center(
                      child: TypewriterAnimatedTextKit(
                      text: ['no added contacts'],
                      speed: Duration(milliseconds: 50),
                      totalRepeatCount: 1,
                      textStyle: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ))
              : Container(),
          inAsyncCall: showSpinner),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddContactPress,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void getUserContacts() async {
    displaySpinner();

    UserProfile currentUserProfile;
    List<UserProfile> currentUserContacts = [];

    try {
      final authUser = await _userService.getCurrentUser();
      currentUserProfile =
          await _userService.getUserProfileByEmail(authUser.email);
      currentUserContacts =
          await _userService.getUserContacts(currentUserProfile.email);
    } catch (e) {
      print(e);
    } finally {
      hideSpinner();
    }

    setState(() {
      currentUser = currentUserProfile;
    });

    setState(() {
      userContacts = currentUserContacts;
    });
  }

  void onAddContactPress() async {
    String invitedUsername;

    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add a new contact'),
            content: SingleChildScrollView(
                child: ListBody(
              children: <Widget>[
                Text('Type the username of the person to get connected with:'),
                TextField(
                  onChanged: (value) => invitedUsername = value,
                ),
              ],
            )),
            actions: <Widget>[
              RaisedButton(
                child: Text('Send'),
                elevation: 5.0,
                color: Colors.blueAccent,
                onPressed: () async {
                  if (invitedUsername != null && invitedUsername.isNotEmpty)
                    await sendInvitation(invitedUsername);
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                child: Text('Cancel'),
                elevation: 5.0,
                color: Colors.blueGrey,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void sendInvitation(String invitedUsername) async {
    final currentUser = await _userService.getCurrentUser();
    final inviterUserProfile =
        await _userService.getUserProfileByEmail(currentUser.email);

    final invitation = UserInvitation(inviterUserProfile, invitedUsername);

    try {
      _userService.setUserInvitation(invitation);
    } catch (e) {
      print(e);
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

class UserContactsList extends StatelessWidget {
  final UserProfile currentUser;
  final UserProfile userContact;

  const UserContactsList({this.currentUser, this.userContact});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(5),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, ChatScreen.routeName,
                arguments: ChatScreenArguments(currentUser, userContact));
          },
          child: Card(
            child: Row(
              children: <Widget>[
                Icon(Icons.person, size: 60),
                Expanded(
                    child: ListTile(
                  title:
                      Text(userContact.firstName + ' ' + userContact.lastName),
                  subtitle:
                      Text(userContact.username + ' | ' + userContact.email),
                )),
              ],
            ),
          ),
        ));
  }
}
