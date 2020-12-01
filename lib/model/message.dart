class Message {
  static const CREATED_AT = 'createdAt';
  static const CREATED_BY = 'createdBy';
  static const DISPLAY_NAME = 'displayName';
  static const TEXT = 'text';

  String docId;
  DateTime createdAt;
  String createdBy;
  String displayName;
  String text;

  Message({this.docId, this.createdAt, this.createdBy, this.displayName, this.text});

  Map<String, dynamic> serialize() {
    return <String, dynamic> {
      CREATED_AT: createdAt,
      CREATED_BY: createdBy,
      DISPLAY_NAME: displayName,
      TEXT: text,
    };
  }

  static Message deserialize(Map<String, dynamic> data,) {
    return Message(
      
      createdAt: data[Message.CREATED_AT] != null ? DateTime.fromMillisecondsSinceEpoch(data[Message.CREATED_AT].millisecondsSinceEpoch) : null,
      createdBy: data[Message.CREATED_BY],
      displayName: data[Message.DISPLAY_NAME],
      text: data[Message.TEXT],
    );
  }
}