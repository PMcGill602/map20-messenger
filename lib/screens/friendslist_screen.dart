import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/chat.dart';
import 'package:messengerapp/model/groupchat.dart';
import 'package:messengerapp/model/message.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/messages_screen.dart';
import 'package:messengerapp/screens/views/mydialog.dart';
import 'package:messengerapp/screens/views/myimageview.dart';

class FriendsListScreen extends StatefulWidget {
  static const routeName =
      '/signInScreen/homeScreen/profileScreen/friendsListScreen';
  @override
  State<StatefulWidget> createState() {
    return _FriendsListState();
  }
}

class _FriendsListState extends State<FriendsListScreen> {
  _Controller con;
  StoredUserInfo user;
  List<StoredUserInfo> friends;
  GroupChat groupChat;
  bool groupChatAdd;
  List<StoredUserInfo> inGroupChat = [];
  List<StoredUserInfo> added = [];

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
    groupChat ??= arg['groupChat'];
    groupChatAdd ??= arg['groupChatAdd'];
    return WillPopScope(
      onWillPop:
          groupChatAdd ? () => Future.value(false) : () => Future.value(true),
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: groupChatAdd ? false : true,
            title: Text('Friends list'),
          ),
          body: friends.isNotEmpty
              ? Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: friends.length,
                        itemBuilder: (BuildContext context, int index) =>
                            Container(
                              child: ListTile(
                                leading: ClipOval(
                                    child: MyImageView.network(
                                        imageUrl: friends[index].photoUrl,
                                        context: context)),
                                title: Text(friends[index].displayName),
                                subtitle: Text(friends[index].email),
                                trailing: Wrap(
                                  children: <Widget>[
                                    groupChatAdd
                                        ? SizedBox(
                                            width: 0,
                                          )
                                        : IconButton(
                                            icon: Icon(Icons.mail),
                                            onPressed: () =>
                                                con.messagesNavigate(
                                                    friends[index], user)),
                                    groupChatAdd
                                        ? IconButton(
                                            icon: Icon(Icons.check),
                                            onPressed: () => con
                                                .addToGroupChat(friends[index]),
                                          )
                                        : IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: () => con.unfriend(
                                                friends[index], user, index))
                                  ],
                                ),
                              ),
                            )),
                    Container(
                      child: groupChatAdd
                          ? RaisedButton(
                              child: Text('Return'),
                              onPressed: con.returnToGroupChat,
                            )
                          : SizedBox(
                              width: 0,
                            ),
                    )
                  ],
                )
              : Column(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'No friends',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Container(
                      child: groupChatAdd
                          ? RaisedButton(
                              child: Text('Return'),
                              onPressed: con.returnToGroupChat,
                            )
                          : SizedBox(
                              width: 0,
                            ),
                    ),
                  ],
                )),
    );
  }
}

class _Controller {
  _FriendsListState _state;
  _Controller(this._state);

  void messagesNavigate(StoredUserInfo friend, StoredUserInfo user) async {
    try {
      var c = Chat();
      c = await FireBaseController.getChat(user: user, friend: friend);
      var m = <Message>[];
      if (c.messages != null && c.messages.length != 0) {
        for (var message in c.messages) {
          m.add(Message.deserialize(message));
        }
      }

      await Navigator.pushNamed(_state.context, MessagesScreen.routeName,
          arguments: {
            'user': user,
            'friend': friend,
            'chat': c,
            'messages': m
          });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Messages error, try again later',
        content: e.toString(),
      );
    }
  }

  void unfriend(
      StoredUserInfo toUnfriend, StoredUserInfo user, int index) async {
    MyDialog.prompt(
        context: _state.context,
        title: 'Are you sure you want to unfriend this user?',
        content: 'This cannot be undone',
        fn: () async {
          try {
            await FireBaseController.unfriendUser(
                user: user, toUnfriend: toUnfriend);
            Navigator.of(_state.context).pop();
            _state.render(() => _state.friends.removeAt(index));
          } catch (e) {
            MyDialog.info(
              context: _state.context,
              title: 'Error unfriending user, try again later',
              content: e.message ?? e.toString(),
            );
          }
        });
  }

  void addToGroupChat(StoredUserInfo toAdd) async {
    try {
      await FireBaseController.addToGroupChat(
          toAdd: toAdd, g: _state.groupChat);
      _state.added.add(toAdd);
      MyDialog.info(
          context: _state.context, title: "Successfully added", content: '');
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error adding user to group chat, try again later',
        content: e.toString(),
      );
    }
  }

  void returnToGroupChat() async {
    try {
      for (var user in _state.added) {
        _state.groupChat.userIds.add(user.uid);
      }
      var updatedMembers =
          await FireBaseController.getGroupChatMembers(_state.groupChat);
      Navigator.pop(_state.context, updatedMembers);
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error returning to group chat',
        content: e.toString(),
      );
    }
  }
}
