import 'package:flash_chat/models/user_invitation.dart';
import 'package:flash_chat/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class InvitationsScreen extends StatefulWidget {
  static const String routeName = 'invitationsScreen';

  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final UserService _userService = UserService.instance;

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
                return Invitation(
                    userInvitation, acceptUserInvitation, rejectUserInvitation);
              }),
          inAsyncCall: showSpinner),
    );
  }

  Future<void> getUserInvitations() async {
    displaySpinner();

    List<UserInvitation> userInvitationsList = [];

    try {
      final user = await _userService.getCurrentUser();
      final userProfile = await _userService.getUserProfileByEmail(user.email);

      if (userProfile != null) {
        userInvitationsList =
            await _userService.getUserInvitations(userProfile.username);
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

  void acceptUserInvitation(UserInvitation invitation) async {
    displaySpinner();

    try {
      await _userService.acceptInvitation(invitation);
      await getUserInvitations();
    } catch (e) {
      print(e);
    }

    hideSpinner();
  }

  void rejectUserInvitation(UserInvitation invitation) async {
    displaySpinner();

    try {
      await _userService.deleteInvitation(invitation);
      await getUserInvitations();
    } catch (e) {
      print(e);
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

class Invitation extends StatelessWidget {
  UserInvitation invitation;
  Function(UserInvitation) acceptUserInvitation;
  Function(UserInvitation) rejectUserInvitation;

  Invitation(UserInvitation invitation, Function acceptUserInvitation,
      Function rejectUserInvitation) {
    this.invitation = invitation;
    this.acceptUserInvitation = acceptUserInvitation;
    this.rejectUserInvitation = rejectUserInvitation;
  }

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
                    onPressed: onAcceptUserInvitation),
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
                    onPressed: onRejectUserInvitation),
              ),
              padding: EdgeInsets.all(10),
            ),
          ],
        ),
      ),
    );
  }

  onAcceptUserInvitation() async {
    await acceptUserInvitation(invitation);
  }

  onRejectUserInvitation() async {
    await rejectUserInvitation(invitation);
  }
}
