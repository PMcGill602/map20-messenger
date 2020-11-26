import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/post.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/post_screen.dart';
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
  StoredUserInfo user;
  StoredUserInfo profile;
  bool friends;
  List<Post> posts;
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
    posts ??= arg['posts'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      floatingActionButton: user.uid == profile.uid
          ? FloatingActionButton(
              child: Icon(Icons.add_comment),
              onPressed: con.newPostNavigate,
            )
          : null,
      body: Column(children: <Widget>[
        Text(profile.email),
        user.uid != profile.uid
            ? friends
                ? Text('We are friends')
                : Column(
                    children: <Widget>[
                      Text('We are not friends'),
                      RaisedButton(
                          onPressed: con.sendRequest,
                          child: Text('Send friend request'))
                    ],
                  )
            : Text('Its me!'),
        Flexible(
          child: !friends && user.uid != profile.uid
              ? Text("Become friends to see this user's posts")
              : posts != null
                  ? ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Container(
                            child: ListTile(
                              title: Text(posts[index].message),
                            ),
                          ))
                  : Text('No posts'),
        )
      ]),
    );
  }
}

class _Controller {
  _ProfileState _state;
  _Controller(this._state);
  String post;

  void sendRequest() async {
    MyDialog.circularProgressStart(_state.context);
    try {
      await FireBaseController.sendFriendRequest(
          sender: _state.user, recipient: _state.profile);
      MyDialog.circularProgressEnd(_state.context);
      MyDialog.info(
        context: _state.context,
        title: 'Friend request sent!',
        content: '',
      );
    } catch (e) {
      MyDialog.circularProgressEnd(_state.context);
      MyDialog.info(
        context: _state.context,
        title: 'Friend request error',
        content: e.toString(),
      );
    }
  }

  void newPostNavigate() async {
    await Navigator.pushNamed(_state.context, PostScreen.routeName,
        arguments: {'user': _state.user, 'posts': _state.posts});
    _state.render(() {});
  }
}
