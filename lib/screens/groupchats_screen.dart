import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/groupchat.dart';
import 'package:messengerapp/model/message.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/groupchatdetailed_screen.dart';
import 'package:messengerapp/screens/views/mydialog.dart';

class GroupChatsScreen extends StatefulWidget {
  static const routeName = '/signInScreen/homeScreen/groupChatsScreen';
  @override
  State<StatefulWidget> createState() {
    return _GroupChatsState();
  }
}

class _GroupChatsState extends State<GroupChatsScreen> {
  _Controller con;
  StoredUserInfo user;
  List<StoredUserInfo> friends;
  List<GroupChat> groupChats;
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
    groupChats ??= arg['groupChats'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Group chats'),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: con.makeGroupChat),
      body: Column(children: <Widget>[
        Flexible(
            child: groupChats != null
                ? ListView.builder(
                    itemCount: groupChats.length,
                    itemBuilder: (BuildContext context, int index) => Container(
                          child: ListTile(
                            title: Text(groupChats[index].name),
                            subtitle: groupChats[index].ownerId == user.uid
                                ? Text('You own this')
                                : SizedBox(
                                    width: 0,
                                  ),
                            trailing: Wrap(
                              children: <Widget>[
                                groupChats[index].ownerId != user.uid
                                    ? IconButton(
                                        icon: Icon(Icons.exit_to_app),
                                        onPressed: () => con.leave(groupChats[index]))
                                    : IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: con.delete),
                              ],
                            ),
                            onTap: () => con
                                .groupChatDetailedNavigate(groupChats[index]),
                          ),
                        ))
                : Text('No group chats')),
      ]),
    );
  }
}

class _Controller {
  _GroupChatsState _state;
  _Controller(this._state);

  void makeGroupChat() async {
    try {
      var m = <Message>[];
      var g = GroupChat(
        ownerId: _state.user.uid,
        members: [_state.user.serialize()],
        messages: m,
        userIds: [_state.user.uid],
        name: 'New group chat',
      );
      g.docId = await FireBaseController.createGroupChat(g: g);
      _state.render(() => _state.groupChats.add(g));
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Group chat creation error',
        content: e.message ?? e.toString(),
      );
    }
  }

  void groupChatDetailedNavigate(GroupChat g) async {
    try {
      var m = <Message>[];
      for (var message in g.messages) {
        m.add(Message.deserialize(message));
      }
      await Navigator.pushNamed(
          _state.context, GroupChatDetailedScreen.routeName, arguments: {
        'groupChat': g,
        'messages': m,
        'user': _state.user,
        'friends': _state.friends
      });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Group chats detailed error',
        content: e.message ?? e.toString(),
      );
    }
  }

  void delete() {}

  void leave(GroupChat g) async{
    try {
      await FireBaseController.leaveGroupChat(toLeave: _state.user, g: g);
      _state.render(() => _state.groupChats.remove(g));
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error leaving group chat',
        content: e.message ?? e.toString(),
      );
    }
  }
}
