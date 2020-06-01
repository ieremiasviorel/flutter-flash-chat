class Message {
  String senderEmail;
  String receiverEmail;
  List<String> participants;
  String messageText;
  int messageTimestamp;

  Message(this.senderEmail, this.receiverEmail, this.messageText,
      this.messageTimestamp) {
    this.participants =
        Message.createParticipantsField(this.senderEmail, this.receiverEmail);
  }

  Message.fromJson(Map<String, dynamic> messageJson) {
    this.senderEmail = messageJson['senderEmail'];
    this.receiverEmail = messageJson['receiverEmail'];
    this.participants = (messageJson['participants'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    this.messageText = messageJson['messageText'];
    this.messageTimestamp = messageJson['messageTimestamp'];
  }

  static List<String> createParticipantsField(
      String userEmailA, String userEmailB) {
    return userEmailA.compareTo(userEmailB) <= 0
        ? [userEmailA, userEmailB]
        : [userEmailB, userEmailA];
  }

  static Map<String, dynamic> toJson(Message message) {
    final messageMap = new Map<String, dynamic>();
    messageMap['senderEmail'] = message.senderEmail;
    messageMap['receiverEmail'] = message.receiverEmail;
    messageMap['participants'] = message.participants;
    messageMap['messageText'] = message.messageText;
    messageMap['messageTimestamp'] = message.messageTimestamp;

    return messageMap;
  }
}
