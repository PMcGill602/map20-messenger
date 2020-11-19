import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/storeduserinfo.dart';

class FriendRequestsScreen extends StatefulWidget {
  static const routeName = '/signInScreen/homeScreen/friendRequestsScreen';
  @override
  State<StatefulWidget> createState() {
    return _FriendRequestsState();
  }
}

class _FriendRequestsState extends State<FriendRequestsScreen> {
  _Controller con;
  User user;
  List<StoredUserInfo> requests;

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
    requests ??= arg['requests'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
      ),
      body: requests != null
          ? ListView.builder(
              itemCount: requests.length,
              itemBuilder: (BuildContext context, int index) => Container(
                    child: ListTile(
                      leading: Icon(Icons.face), //user profile image
                      title: Text(requests[index].displayName),
                      subtitle: Text(requests[index].email),
                      trailing: Wrap(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () =>
                                con.accept(requests[index], user, index),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                            ),
                            onPressed: () =>
                                con.decline(requests[index], user, index),
                          ),
                        ],
                      ),
                    ),
                  ))
          : Text('No requests'),
    );
  }
}

class _Controller {
  _FriendRequestsState _state;
  _Controller(this._state);

  void accept(StoredUserInfo toAccept, User user, int index) async {
    await FireBaseController.acceptRequest(toAccept: toAccept, user: user);
    _state.render(() => _state.requests.removeAt(index));
  }

  void decline(StoredUserInfo toDecline, User user, int index) async {
    await FireBaseController.declineRequest(user: user, toDecline: toDecline);
    _state.render(() => _state.requests.removeAt(index));
  }
}
