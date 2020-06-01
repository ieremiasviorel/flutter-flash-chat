import 'package:flash_chat/models/user_profile.dart';

import 'message.dart';

class Conversation {
  UserProfile currentUser;
  UserProfile otherUser;
  Message lastMessage;

  Conversation(this.currentUser, this.otherUser, this.lastMessage);
}
