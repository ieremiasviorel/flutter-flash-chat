import 'package:flash_chat/models/user_invitation.dart';
import 'package:flash_chat/models/user_profile.dart';
import 'package:flash_chat/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ContactsScreen extends StatefulWidget {
  static const String routeName = 'contactsScreen';

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final UserService _userService = UserService.instance;

  List<UserProfile> userContacts = new List<UserProfile>();
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
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: userContacts.length,
              itemBuilder: (context, index) {
                final userContact = userContacts[index];
                return UserContactsList(userContact: userContact);
              }),
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

    List<UserProfile> userContactsList = [];

    try {
      final currentUser = await _userService.getCurrentUser();
      userContactsList = await _userService.getUserContacts(currentUser.email);
    } catch (e) {
      print(e);
    } finally {
      hideSpinner();
    }

    setState(() {
      userContacts = userContactsList;
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
  final UserProfile userContact;

  const UserContactsList({this.userContact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Card(
        child: Row(
          children: <Widget>[
            Icon(Icons.person, size: 60),
            Expanded(
                child: ListTile(
              title: Text(userContact.firstName + ' ' + userContact.lastName),
              subtitle: Text(userContact.username + ' | ' + userContact.email),
            )),
          ],
        ),
      ),
    );
  }
}
