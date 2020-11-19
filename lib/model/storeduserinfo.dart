class StoredUserInfo {
  static const COLLECTION = 'users';
  static const UID = 'uid';
  static const EMAIL = 'email';
  static const DISPLAY_NAME = 'displayName';
  static const BIOGRAPHY = 'biography';
  static const FRIENDS = 'friends';
  static const REQUESTS = 'requests';

  String docId;
  String uid;
  String email;
  String displayName;
  String biography;
  List<dynamic> friends;
  Map<String, dynamic> requests;

  StoredUserInfo(
      {this.docId,
      this.uid,
      this.email,
      this.displayName,
      this.biography,
      this.friends,
      this.requests}) {
    this.friends ??= [];
    this.requests ??= {};
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      UID: uid,
      EMAIL: email,
      DISPLAY_NAME: displayName,
      BIOGRAPHY: biography,
      FRIENDS: friends,
      REQUESTS: requests,
    };
  }

  static StoredUserInfo deserialize(Map<String, dynamic> data, String docId) {
    return StoredUserInfo(
        docId: docId,
        uid: data[StoredUserInfo.UID],
        email: data[StoredUserInfo.EMAIL],
        displayName: data[StoredUserInfo.DISPLAY_NAME],
        biography: data[StoredUserInfo.BIOGRAPHY],
        friends: data[StoredUserInfo.FRIENDS],
        requests: data[StoredUserInfo.REQUESTS]);
  }

  @override
  String toString() {
    return 'docId: $docId uid: $uid email: $email displayName: $displayName  \n  biography: $biography';
  }
}
