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
import 'package:messengerapp/screens/views/myimageview.dart';

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
  List<Post> friendPosts;
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
    friendPosts ??= arg['friendPosts'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: con.searchNavigate)
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
                currentAccountPicture: ClipOval(
                    child: MyImageView.network(
                  imageUrl: user.photoUrl,
                  context: context,
                )),
                accountName: Text(user.email),
                accountEmail: Text(user.displayName ?? 'N/A')),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: con.profileNavigate,
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Friends'),
              onTap: con.friendsListNavigate,
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Friend Requests'),
              onTap: con.friendRequestsNavigate,
            ),
            ListTile(
              leading: Icon(Icons.chat_bubble),
              title: Text('Group Chats'),
              onTap: con.groupChatsNavigate,
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: con.signOut,
            ),
          ],
        ),
      ),
      body: Column(children: <Widget>[
        Flexible(
          child: friendPosts.length != 0
              ? ListView.builder(
                  itemCount: friendPosts.length,
                  itemBuilder: (BuildContext context, int index) => Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                leading: ClipOval(
                                    child: MyImageView.network(
                                        imageUrl: friends
                                            .where((element) =>
                                                element.uid ==
                                                friendPosts[index].createdBy)
                                            .first
                                            .photoUrl,
                                        context: context)),
                                title: Text(friendPosts[index].message),
                                subtitle: Text(friends.where((element) => element.uid == friendPosts[index].createdBy).first.displayName),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            )
                          ],
                        ),
                      ))
              : Container(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'No posts from friends',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
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
      var updatedProfile = await Navigator.pushNamed(
          _state.context, ProfileScreen.routeName,
          arguments: {
            'profile': _state.user,
            'user': _state.user,
            'posts': posts,
            'friends': true,
          });
      _state.render(() {
        _state.user = updatedProfile;
      });
      Navigator.pop(_state.context);
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
      var result = await Navigator.pushNamed(
          _state.context, FriendRequestsScreen.routeName, arguments: {
        'user': _state.user,
        'requests': requests,
        'friends': _state.friends
      });
      _state.render(() => _state.friends = result);
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Friend requests error',
        content: e.message ?? e.toString(),
      );
    }
  }

  void friendsListNavigate() async {
    try {
      await Navigator.pushNamed(_state.context, FriendsListScreen.routeName,
          arguments: {
            'user': _state.user,
            'friends': _state.friends,
            'groupChat': null,
            'groupChatAdd': false
          });
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
      List<GroupChat> groupChats =
          await FireBaseController.getGroupChats(user: _state.user);
      await Navigator.pushNamed(_state.context, GroupChatsScreen.routeName,
          arguments: {
            'user': _state.user,
            'friends': _state.friends,
            'groupChats': groupChats
          });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Group chats error',
        content: e.message ?? e.toString(),
      );
    }
  }
}
