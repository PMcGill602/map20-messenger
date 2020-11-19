import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/friendrequests_screen.dart';
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
  User user;
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
              onTap: con.friendRequests,
            ),
          ],
        ),
      ),
      body: Column(children: <Widget>[
        FlatButton(
          child: Text('Find friends'),
          onPressed: con.searchNavigate,
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

  void friendRequests() async {
    try {
      List<StoredUserInfo> requests = await FireBaseController.getRequests(user: _state.user);
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
}
