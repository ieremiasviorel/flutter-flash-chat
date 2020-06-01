class Message {
  String senderEmail;
  String receiverEmail;
  String messageText;
  int messageTimestamp;

  Message(this.senderEmail, this.receiverEmail, this.messageText,
      this.messageTimestamp);

  Message.fromJson(Map messageJson) {
    this.senderEmail = messageJson['senderEmail'];
    this.receiverEmail = messageJson['receiverEmail'];
    this.messageText = messageJson['messageText'];
    this.messageTimestamp = messageJson['messageTimestamp'];
  }
}
