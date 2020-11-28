import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/groupchat.dart';
import 'package:messengerapp/model/post.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/friendrequests_screen.dart';
import 'package:messengerapp/screens/friendslist_screen.dart';
import 'package:messengerapp/screens/groupchats_screen.dart';
import 'package:messengerapp/screens/profile_screen.dart';
import 'package:messengerapp/screens/search_screen.dart';
import 'package:messengerapp/screens/signin_screen.dart';
import 'package:messengerapp/screens/views/mydialog.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/signInScreen/homeScreen';
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeScreen> {
  _Controller con;
  StoredUserInfo user;
  List<StoredUserInfo> friends;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    user ??= arg['user'];
    friends ??= arg['friends'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
                //currentAccountPicture
                accountName: Text(user.email),
                accountEmail: Text(user.displayName ?? 'N/A')),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: con.signOut,
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Friend Requests'),
              onTap: con.friendRequestsNavigate,
            ),
          ],
        ),
      ),
      body: Column(children: <Widget>[
        RaisedButton(
          child: Text('Find friends'),
          onPressed: con.searchNavigate,
        ),
        RaisedButton(
          child: Text('My profile'),
          onPressed: con.profileNavigate,
        ),
        RaisedButton(
          child: Text('Friends list'),
          onPressed: con.friendsListNavigate,
        ),
        RaisedButton(
          child: Text('Group chats'),
          onPressed: con.groupChatsNavigate,
        ),
      ]),
    );
  }
}

class _Controller {
  _HomeState _state;
  _Controller(this._state);

  void signOut() async {
    try {
      await FireBaseController.signOut();
    } catch (e) {
      print('signOut exception: ${e.message}');
    }
    Navigator.pushReplacementNamed(_state.context, SignInScreen.routeName);
  }

  void searchNavigate() async {
    await Navigator.pushNamed(_state.context, SearchScreen.routeName,
        arguments: {'user': _state.user});
    _state.render(() {});
  }

  void profileNavigate() async {
    try {
      List<Post> posts;
      posts = await FireBaseController.getPosts(user: _state.user);
      await Navigator.pushNamed(_state.context, ProfileScreen.routeName,
          arguments: {
            'profile': _state.user,
            'user': _state.user,
            'posts': posts,
            'friends': true,
          });
      _state.render(() {});
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error accessing profile',
        content: e.message ?? e.toString(),
      );
    }
  }

  void friendRequestsNavigate() async {
    try {
      List<StoredUserInfo> requests =
          await FireBaseController.getRequests(user: _state.user);
      await Navigator.pushNamed(_state.context, FriendRequestsScreen.routeName,
          arguments: {'user': _state.user, 'requests': requests});
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Friend requests error',
        content: e.message ?? e.toString(),
      );
    }
    _state.render(() {});
  }

  void friendsListNavigate() async {
    try {
      await Navigator.pushNamed(_state.context, FriendsListScreen.routeName,
          arguments: {'user': _state.user, 'friends': _state.friends, 'groupChat': null, 'groupChatAdd' : false});
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Friends list error',
        content: e.message ?? e.toString(),
      );
    }
  }

  void groupChatsNavigate() async {
    try {
      List<GroupChat> groupChats = await FireBaseController.getGroupChats(user: _state.user);
      await Navigator.pushNamed(_state.context, GroupChatsScreen.routeName,
          arguments: {'user': _state.user, 'friends': _state.friends, 'groupChats' : groupChats});
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Group chats error',
        content: e.message ?? e.toString(),
      );
    }
  }
}
