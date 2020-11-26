class Post {
  static const COLLECTION = 'posts';
  static const MESSAGE = 'message';
  static const CREATED_BY = 'createdBy';

  String docId;
  String message;
  String createdBy;

  Post({this.docId, this.message, this.createdBy}) {

  }

  Map<String, dynamic> serialize() {
    return <String, dynamic> {
      MESSAGE: message,
      CREATED_BY: createdBy,
    };
  }

  static Post deserialize(Map<String,dynamic> data, String docId) {
    return Post(
      docId: docId,
      message: data[Post.MESSAGE],
      createdBy: data[Post.CREATED_BY],
    );
  }
}