import 'package:flash_chat/models/user_profile.dart';

class UserInvitation {
  UserProfile inviter;
  String invited;

  UserInvitation(this.inviter, this.invited);

  UserInvitation.fromJson(Map invitationJson) {
    this.inviter = UserProfile.fromJson(invitationJson['inviter']);
    this.invited = invitationJson['invited'];
  }

  static Map<String, dynamic> toJson(UserInvitation userInvitation) {
    final userInvitationMap = new Map<String, dynamic>();
    userInvitationMap['inviter'] = UserProfile.toJson(userInvitation.inviter);
    userInvitationMap['invited'] = userInvitation.invited;

    return userInvitationMap;
  }
}
