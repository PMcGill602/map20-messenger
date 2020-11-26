class Message {
  static const CREATED_AT = 'createdAt';
  static const CREATED_BY = 'createdBy';
  static const TEXT = 'text';

  String docId;
  DateTime createdAt;
  String createdBy;
  String text;

  Message({this.docId, this.createdAt, this.createdBy, this.text});

  Map<String, dynamic> serialize() {
    return <String, dynamic> {
      CREATED_AT: createdAt,
      CREATED_BY: createdBy,
      TEXT: text,
    };
  }

  static Message deserialize(Map<String, dynamic> data,) {
    return Message(
      
      createdAt: data[Message.CREATED_AT] != null ? DateTime.fromMillisecondsSinceEpoch(data[Message.CREATED_AT].millisecondsSinceEpoch) : null,
      createdBy: data[Message.CREATED_BY],
      text: data[Message.TEXT],
    );
  }
}