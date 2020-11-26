class GroupChat {
  static const COLLECTION = 'groupchat';
  static const MESSAGES = 'messages';
  static const OWNERID = 'ownerId';
  static const MEMBERS = 'members';
  static const USERIDS = 'userIds';
  static const NAME = 'name';

  String docId;
  List<dynamic> messages;
  String ownerId;
  List<dynamic> members;
  List<dynamic> userIds;
  String name;

  GroupChat({this.docId, this.messages, this.ownerId, this.members, this.userIds, this.name}) {
    this.messages ??= [];
    this.members ??= [];
    this.userIds ??= [];
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic> {
      MESSAGES: messages,
      OWNERID: ownerId,
      MEMBERS: members,
      USERIDS: userIds,
      NAME: name,
    };
  }

  static GroupChat deserialize(Map<String, dynamic> data, String docId) {
    return GroupChat(
      docId: docId,
      messages: data[MESSAGES],
      ownerId: data[OWNERID],
      members: data[MEMBERS],
      userIds: data[USERIDS],
      name: data[NAME],
    );
  }
}