class Message {
  final String message;
  final String userId;
  final DateTime time = DateTime.now();

  Message(this.message, this.userId);
}
