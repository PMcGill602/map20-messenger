import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/signInScreen/homeScreen/searchScreen';
  @override
  State<StatefulWidget> createState() {
    return _SearchState();
  }
}

class _SearchState extends State<SearchScreen> {
  _Controller con;
  User user;
  var formKey = GlobalKey<FormState>();
  List<StoredUserInfo> searchResults;
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
        title: Text('Search'),
        actions: <Widget>[
          Container(
            width: 300.0,
            padding: EdgeInsets.fromLTRB(
              5,
              5,
              20,
              5,
            ),
            child: Form(
              key: formKey,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: 'Search for users',
                    fillColor: Colors.white,
                    filled: true),
                autocorrect: false,
                onSaved: con.onSavedSearchKey,
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.search), onPressed: con.search),
        ],
      ),
      body: searchResults == null
          ? Text(
              'No results',
              style: TextStyle(fontSize: 30.0),
            )
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (BuildContext context, int index) => Container(
                    child: ListTile(
                      leading: Icon(Icons.face), //user profile image
                      title: Text(searchResults[index].displayName),
                      subtitle: Text(searchResults[index].email),
                      onTap: () => con.profile(index),
                    ),
                  )),
    );
  }
}

class _Controller {
  _SearchState _state;
  _Controller(this._state);
  String searchKey;

  void onSavedSearchKey(String value) {
    searchKey = value;
  }

  void search() async {
    _state.formKey.currentState.save();
    List<StoredUserInfo> results;
    if (searchKey == null || searchKey.trim().isEmpty) {
      return;
    } else {
      results = await FireBaseController.searchUsers(searchKey: searchKey);
    }
    _state.render(() => _state.searchResults = results);
  }

  void profile(int index) async{
    bool friends = await FireBaseController.checkFriends(_state.user, _state.searchResults[index]);
    await Navigator.pushNamed(
      _state.context, ProfileScreen.routeName, arguments: {'profile': _state.searchResults[index], 'user': _state.user, 'friends': friends}
    );
    _state.render((){});
  }
}
