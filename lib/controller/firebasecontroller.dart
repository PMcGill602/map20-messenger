import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messengerapp/model/chat.dart';
import 'package:messengerapp/model/groupchat.dart';
import 'package:messengerapp/model/message.dart';
import 'package:messengerapp/model/post.dart';
import 'package:messengerapp/model/storeduserinfo.dart';

class FireBaseController {
  static Future signIn(String email, String password) async {
    UserCredential auth =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return auth.user;
  }

  static Future signUp(
      String email, String password, String displayName) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await FirebaseAuth.instance.currentUser
        .updateProfile(displayName: displayName);
    User newUser = FirebaseAuth.instance.currentUser;
    StoredUserInfo storedNewUser = StoredUserInfo(
        uid: newUser.uid,
        email: newUser.email,
        displayName: newUser.displayName);
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .add(storedNewUser.serialize());
  }

  static Future signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<StoredUserInfo> getThisUser({@required User user}) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .where(StoredUserInfo.UID, isEqualTo: user.uid)
        .get();
    StoredUserInfo thisUser = StoredUserInfo.deserialize(
        userSnapshot.docs.first.data(), userSnapshot.docs.first.id);
    return thisUser;
  }

  static Future<List<StoredUserInfo>> searchUsers({
    @required String searchKey,
  }) async {
    QuerySnapshot displayNameSnapshot = await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .where(StoredUserInfo.DISPLAY_NAME, isEqualTo: searchKey)
        .get();
    QuerySnapshot emailSnapshot = await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .where(StoredUserInfo.EMAIL, isEqualTo: searchKey)
        .get();
    var displayNameArray = displayNameSnapshot.docs;
    var emailArray = emailSnapshot.docs;
    var finalArray = displayNameArray + emailArray;
    var result = <StoredUserInfo>[];
    if (finalArray.length != 0) {
      for (var doc in finalArray) {
        result.add(StoredUserInfo.deserialize(doc.data(), doc.id));
      }
      return result;
    } else
      return null;
  }

  static Future<List<StoredUserInfo>> getRequests(
      {@required StoredUserInfo user}) async {
    var requests = <StoredUserInfo>[];
    if (user.requests.keys.length != 0) {
      QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection(StoredUserInfo.COLLECTION)
          .where(StoredUserInfo.UID, whereIn: user.requests.keys.toList())
          .get();
      if (requestSnapshot != null && requestSnapshot.docs.length != 0) {
        for (var doc in requestSnapshot.docs) {
          requests.add(StoredUserInfo.deserialize(doc.data(), doc.id));
        }
      }
    }
    return requests;
  }

  static Future<bool> checkFriends(
      StoredUserInfo user, StoredUserInfo toBeChecked) async {
    if (user.uid == toBeChecked.uid) {
      return false;
    }
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .where(StoredUserInfo.UID, isEqualTo: toBeChecked.uid)
        .where(StoredUserInfo.FRIENDS, arrayContains: user.uid)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  static Future sendFriendRequest(
      {@required StoredUserInfo sender,
      @required StoredUserInfo recipient}) async {
    if (await checkFriends(sender, recipient)) {
      throw ('Already friends!');
    }
    Map<String, dynamic> map = {'${sender.uid}': 1};
    recipient.requests.addEntries(map.entries);
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(recipient.docId)
        .update(recipient.serialize());
  }

  static Future acceptRequest(
      {@required StoredUserInfo user,
      @required StoredUserInfo toAccept}) async {
    user.friends.add(toAccept.uid);
    toAccept.friends.add(user.uid);
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(user.docId)
        .update(user.serialize());
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(toAccept.docId)
        .update(toAccept.serialize());
    user.requests.remove(toAccept.uid);
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(user.docId)
        .update(user.serialize());
  }

  static Future declineRequest(
      {@required StoredUserInfo user,
      @required StoredUserInfo toDecline}) async {
    user.requests.remove(toDecline.uid);
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(user.docId)
        .update(user.serialize());
  }

  static Future<List<Post>> getPosts({@required StoredUserInfo user}) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(Post.COLLECTION)
        .where(Post.CREATED_BY, isEqualTo: user.uid)
        .get();
    var posts = <Post>[];
    if (snapshot != null && snapshot.docs.length != 0) {
      for (var doc in snapshot.docs) {
        posts.add(Post.deserialize(doc.data(), doc.id));
      }
    }
    return posts;
  }

  static Future makePost(Post p) async {
    await FirebaseFirestore.instance
        .collection(Post.COLLECTION)
        .add(p.serialize());
  }

  static Future<List<StoredUserInfo>> getFriends(
      {@required StoredUserInfo user}) async {
    var friends = <StoredUserInfo>[];
    if (user.friends.length != 0) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(StoredUserInfo.COLLECTION)
          .where(StoredUserInfo.UID, whereIn: user.friends)
          .get();
      if (snapshot != null && snapshot.docs.length != 0) {
        for (var doc in snapshot.docs) {
          friends.add(StoredUserInfo.deserialize(doc.data(), doc.id));
        }
      }
    }
    return friends;
  }

  static Future unfriendUser(
      {@required StoredUserInfo user,
      @required StoredUserInfo toUnfriend}) async {
    user.friends.remove(toUnfriend.uid);
    toUnfriend.friends.remove(user.uid);
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(user.docId)
        .update(user.serialize());
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(toUnfriend.docId)
        .update(toUnfriend.serialize());
  }

  static Future<Chat> getChat(
      {@required StoredUserInfo user, @required StoredUserInfo friend}) async {
    QuerySnapshot snapshot1 = await FirebaseFirestore.instance
        .collection(Chat.COLLECTION)
        .where(Chat.CHATID, isEqualTo: user.uid + '-' + friend.uid)
        .get();
    QuerySnapshot snapshot2 = await FirebaseFirestore.instance
        .collection(Chat.COLLECTION)
        .where(Chat.CHATID, isEqualTo: friend.uid + '-' + user.uid)
        .get();
    if (snapshot1 != null && snapshot1.docs.length != 0) {
      var chat = Chat.deserialize(
          snapshot1.docs.first.data(), snapshot1.docs.first.id);
      return chat;
    } else if (snapshot2 != null && snapshot2.docs.length != 0) {
      var chat = Chat.deserialize(
          snapshot2.docs.first.data(), snapshot2.docs.first.id);
      return chat;
    } else
      return null;
  }

  static Future<String> createChat({@required Chat c}) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Chat.COLLECTION)
        .add(c.serialize());
    return ref.id;
  }

  static Future sendMessage(
      {@required StoredUserInfo sender,
      @required StoredUserInfo receiver,
      @required Message m,
      @required Chat c}) async {
    await FirebaseFirestore.instance
        .collection(Chat.COLLECTION)
        .doc(c.docId)
        .update({
      'messages': FieldValue.arrayUnion([m.serialize()])
    });
  }

  static Future sendGroupChatMessage(
      {@required StoredUserInfo sender,
      @required Message m,
      @required GroupChat g}) async {
    await FirebaseFirestore.instance
        .collection(GroupChat.COLLECTION)
        .doc(g.docId)
        .update({
      'messages': FieldValue.arrayUnion([m.serialize()])
    });
  }

  static Future createGroupChat(
      {@required GroupChat g}) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(GroupChat.COLLECTION)
        .add(g.serialize());
    return ref.id;
  }

  static Future<List<GroupChat>> getGroupChats(
      {@required StoredUserInfo user}) async {
    var groupChats = <GroupChat>[];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(GroupChat.COLLECTION)
        .where(GroupChat.USERIDS, arrayContains: user.uid)
        .get();
    if (snapshot != null && snapshot.docs.length != 0) {
      for (var doc in snapshot.docs) {
        groupChats.add(GroupChat.deserialize(doc.data(), doc.id));
      }
    }
    return groupChats;
  }

  static Future addToGroupChat(
      {@required StoredUserInfo toAdd, @required GroupChat g}) async {
    await FirebaseFirestore.instance
        .collection(GroupChat.COLLECTION)
        .doc(g.docId)
        .update({
      'members': FieldValue.arrayUnion([toAdd.serialize()],), 'userIds' : FieldValue.arrayUnion([toAdd.uid])
    });
  }

  static Future leaveGroupChat({@required StoredUserInfo toLeave, @required GroupChat g}) async{
    g.userIds.remove(toLeave.uid);
    g.members.remove(toLeave);
    await FirebaseFirestore.instance.collection(GroupChat.COLLECTION).doc(g.docId).update(g.serialize());
  }
}
