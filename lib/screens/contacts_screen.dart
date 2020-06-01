import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ContactsScreen extends StatefulWidget {
  static const String routeName = 'contactsScreen';

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _auth = FirebaseAuth.instance;
  final _store = Firestore.instance;

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
                return UserContactComp(userContact: userContact);
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
      final user = await _auth.currentUser();
      if (user != null) {
        final userContactsData = await _store
            .collection('contacts')
            .document(user.email)
            .get()
            .then((userContactsDocument) => userContactsDocument.data);

        if (userContactsData != null) {
          userContactsList = userContactsData['contacts']
              .map<UserProfile>(
                  (userProfileJson) => UserProfile.fromJson(userProfileJson))
              .toList();
        }
      }
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

  void sendInvitation(String username) async {
    _auth
        .currentUser()
        .then(
            (user) => _store.collection('profiles').document(user.email).get())
        .then((userDocument) => userDocument.data)
        .then((userData) => UserProfile.fromJson(userData))
        .then((userProfile) =>
            {'inviter': UserProfile.toJson(userProfile), 'invited': username})
        .then((invitationMap) =>
            _store.collection('invitations').add(invitationMap));
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

class UserContactComp extends StatelessWidget {
  final UserProfile userContact;

  const UserContactComp({this.userContact});

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
