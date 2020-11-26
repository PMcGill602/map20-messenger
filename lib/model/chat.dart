
class Chat {
  static const COLLECTION = 'chat';
  static const MESSAGES = 'messages';
  static const CHATID = 'chatId';

  String docId;
  List<dynamic> messages;
  String chatId;

  Chat({this.docId, this.messages, this.chatId}) {
    this.messages ??= [];
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic> {
      MESSAGES: messages,
      CHATID: chatId,
    };
  }

  static Chat deserialize(Map<String, dynamic> data, String docId) {
    return Chat(
      docId: docId,
      messages: data[MESSAGES],
      chatId: data[CHATID],
    );
  }
}
