import 'package:flash_chat/models/user_profile.dart';

class UserInvitation {
  UserProfile inviter;
  String invited;

  UserInvitation(this.inviter, this.invited);

  UserInvitation.fromJson(Map invitationJson) {
    this.inviter = UserProfile.fromJson(invitationJson['inviter']);
    this.invited = invitationJson['invited'];
  }
}
