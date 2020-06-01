import 'package:flash_chat/models/user_profile.dart';

class ChatScreenArguments {
  UserProfile currentUser;
  UserProfile otherUser;

  ChatScreenArguments(this.currentUser, this.otherUser);
}
