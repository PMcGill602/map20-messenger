import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  static Future<List<StoredUserInfo>> getRequests({@required User user}) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .where(StoredUserInfo.UID, isEqualTo: user.uid)
        .get();
    StoredUserInfo thisUser = StoredUserInfo.deserialize(
        userSnapshot.docs.first.data(), userSnapshot.docs.first.id);
    if (thisUser.requests.keys.length != 0) {
      QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection(StoredUserInfo.COLLECTION)
          .where(StoredUserInfo.UID, whereIn: thisUser.requests.keys.toList())
          .get();
      var requests = <StoredUserInfo>[];
      if (requestSnapshot != null && requestSnapshot.docs.length != 0) {
        for (var doc in requestSnapshot.docs) {
          requests.add(StoredUserInfo.deserialize(doc.data(), doc.id));
        }
      }
      return requests;
    } else
      return null;
  }

  static Future<bool> checkFriends(User user, StoredUserInfo toBeChecked) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .where(StoredUserInfo.UID, isEqualTo: toBeChecked.uid)
        .where(StoredUserInfo.FRIENDS, arrayContains: user.uid)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  static Future sendFriendRequest(
      {@required User sender, @required StoredUserInfo recipient}) async {
    Map<String, dynamic> map = {'${sender.uid}': 1};
    recipient.requests.addEntries(map.entries);
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(recipient.docId)
        .update(recipient.serialize());
  }

  static Future acceptRequest(
      {@required User user, @required StoredUserInfo toAccept}) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .where(StoredUserInfo.UID, isEqualTo: user.uid)
        .get();
    StoredUserInfo thisUser = StoredUserInfo.deserialize(
        userSnapshot.docs.first.data(), userSnapshot.docs.first.id);
    thisUser.friends.add(toAccept.uid);
    toAccept.friends.add(user.uid);
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(thisUser.docId)
        .update(thisUser.serialize());
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(toAccept.docId)
        .update(toAccept.serialize());
  }

  static Future declineRequest(
      {@required User user, @required StoredUserInfo toDecline}) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .where(StoredUserInfo.UID, isEqualTo: user.uid)
        .get();
    StoredUserInfo thisUser = StoredUserInfo.deserialize(
        userSnapshot.docs.first.data(), userSnapshot.docs.first.id);
    thisUser.requests.remove(toDecline.uid);
    await FirebaseFirestore.instance
        .collection(StoredUserInfo.COLLECTION)
        .doc(thisUser.docId)
        .update(thisUser.serialize());
  }
}
