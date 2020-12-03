class StoredUserInfo {
  static const COLLECTION = 'users';
  static const IMAGE_FOLDER = 'profilePictures';
  static const UID = 'uid';
  static const EMAIL = 'email';
  static const DISPLAY_NAME = 'displayName';
  static const BIOGRAPHY = 'biography';
  static const FRIENDS = 'friends';
  static const REQUESTS = 'requests';
  static const PHOTO_URL = 'photoUrl';

  String docId;
  String uid;
  String email;
  String displayName;
  String biography;
  List<dynamic> friends;
  Map<String, dynamic> requests;
  String photoUrl;

  StoredUserInfo({
    this.docId,
    this.uid,
    this.email,
    this.displayName,
    this.biography,
    this.friends,
    this.requests,
    this.photoUrl,
  }) {
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
      PHOTO_URL: photoUrl,
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
      requests: data[StoredUserInfo.REQUESTS],
      photoUrl: data[StoredUserInfo.PHOTO_URL],
    );
  }

  @override
  String toString() {
    return 'docId: $docId uid: $uid email: $email displayName: $displayName  \n  biography: $biography';
  }
}
