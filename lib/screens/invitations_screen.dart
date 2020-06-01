import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/user_invitation.dart';
import 'package:flash_chat/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class InvitationsScreen extends StatefulWidget {
  static const String routeName = 'invitationsScreen';

  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final _auth = FirebaseAuth.instance;
  final _store = Firestore.instance;

  List<UserInvitation> userInvitations = new List<UserInvitation>();
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getUserInvitations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: ModalProgressHUD(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: userInvitations.length,
              itemBuilder: (context, index) {
                final userInvitation = userInvitations[index];
                return Invitation(invitation: userInvitation);
              }),
          inAsyncCall: showSpinner),
    );
  }

  void getUserInvitations() async {
    displaySpinner();

    List<UserInvitation> userInvitationsList = [];

    try {
      final user = await _auth.currentUser();
      if (user != null) {
        final userProfile = await _store
            .collection('profiles')
            .document(user.email)
            .get()
            .then((userProfileDocument) => userProfileDocument.data)
            .then((userProfileJson) => userProfileJson != null
                ? UserProfile.fromJson(userProfileJson)
                : null);

        if (userProfile != null) {
          userInvitationsList = await _store
              .collection('invitations')
              .where('invited', isEqualTo: userProfile.username)
              .getDocuments()
              .then(
                  (invitationsQueryResult) => invitationsQueryResult.documents)
              .then((invitationsDocuments) => invitationsDocuments
                  .map((invitationDocument) => invitationDocument.data)
                  .toList())
              .then((invitationsData) => invitationsData
                  .map((invitationData) =>
                      UserInvitation.fromJson(invitationData))
                  .toList());
        }
      }
    } catch (e) {
      print(e);
    } finally {
      hideSpinner();
    }

    setState(() {
      userInvitations = userInvitationsList;
    });
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

class Invitation extends StatelessWidget {
  final UserInvitation invitation;

  const Invitation({this.invitation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListTile(
                title: Text(invitation.inviter.firstName +
                    ' ' +
                    invitation.inviter.lastName),
                subtitle: Text(invitation.inviter.username +
                    ' | ' +
                    invitation.inviter.email),
              ),
            ),
            Padding(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    icon: Icon(
                      Icons.check,
                      size: 35,
                      color: Colors.green,
                    ),
                    onPressed: () => {print('Pressed')}),
              ),
              padding: EdgeInsets.all(10),
            ),
            Padding(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 35,
                      color: Colors.red,
                    ),
                    onPressed: () => {print('Pressed')}),
              ),
              padding: EdgeInsets.all(10),
            ),
          ],
        ),
      ),
    );
  }
}
