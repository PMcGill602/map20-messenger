import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messengerapp/screens/views/mydialog.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/signInScreen/homeScreen/profileScreen';
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<ProfileScreen> {
  _Controller con;
  User user;
  StoredUserInfo profile;
  bool friends;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    profile ??= arg['profile'];
    user ??= arg['user'];
    friends ??= arg['friends'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Column(children: <Widget>[
        Text(profile.email),
        friends
            ? Text('We are friends')
            : Column(
                children: <Widget>[
                  Text('We are not friends'),
                  RaisedButton(onPressed: con.sendRequest, child: Text('Send friend request'))
                ],
              ),
      ]),
    );
  }
}

class _Controller {
  _ProfileState _state;
  _Controller(this._state);

  void sendRequest() async {
    MyDialog.circularProgressStart(_state.context);
    try {
      await FireBaseController.sendFriendRequest(sender: _state.user, recipient: _state.profile );
      MyDialog.circularProgressEnd(_state.context);
      MyDialog.info(
        context: _state.context,
        title: 'Friend request sent!',
        content: '',
      );
    } catch(e) {
      MyDialog.circularProgressEnd(_state.context);
      MyDialog.info(
        context: _state.context,
        title: 'Friend request error',
        content: e.message ?? e.toString(),
      );
    }
  }
}
