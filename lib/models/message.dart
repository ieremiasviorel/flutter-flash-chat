class Message {
  String senderEmail;
  String receiverEmail;
  List<String> participants;
  String messageText;
  int messageTimestamp;

  Message(this.senderEmail, this.receiverEmail, this.participants,
      this.messageText, this.messageTimestamp);

  Message.fromJson(Map<String, dynamic> messageJson) {
    this.senderEmail = messageJson['senderEmail'];
    this.receiverEmail = messageJson['receiverEmail'];
    this.participants = (messageJson['participants'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    this.messageText = messageJson['messageText'];
    this.messageTimestamp = messageJson['messageTimestamp'];
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
