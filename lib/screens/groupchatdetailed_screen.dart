import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/groupchat.dart';
import 'package:messengerapp/model/message.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/friendslist_screen.dart';
import 'package:messengerapp/screens/views/mydialog.dart';

class GroupChatDetailedScreen extends StatefulWidget {
  static const routeName =
      '/signInScreen/homeScreen/groupChatsScreen/groupChatDetailedScreen';
  @override
  State<StatefulWidget> createState() {
    return _GroupChatDetailedState();
  }
}

class _GroupChatDetailedState extends State<GroupChatDetailedScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  GroupChat groupChat;
  List<Message> messages;
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
    groupChat ??= arg['groupChat'];
    messages ??= arg['messages'];
    user ??= arg['user'];
    friends ??= arg['friends'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${groupChat.name}',
        ),
        actions: <Widget>[
          user.uid == groupChat.ownerId ? IconButton(icon: Icon(Icons.add), onPressed: con.addMembers) : SizedBox(width: 0,)
        ],
      ),
      body: Column(
        children: <Widget>[
          Text('Start of message history'),
          Flexible(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) => Container(
                padding: messages[index].createdBy != user.uid
                    ? EdgeInsets.fromLTRB(10, 5, 250, 5)
                    : EdgeInsets.fromLTRB(250, 5, 5, 5),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(messages[index].text),
                      subtitle: Text(messages[index].createdAt.toString()),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Form(
            key: formKey,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Send a message",
              ),
              autocorrect: true,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              validator: con.validatorMessage,
              onSaved: con.onSavedMessage,
            ),
          ),
          RaisedButton(
            child: Text('Send'),
            onPressed: con.sendMessage,
          ),
        ],
      ),
    );
  }
}

class _Controller {
  _GroupChatDetailedState _state;
  _Controller(this._state);
  String message;

  String validatorMessage(String value) {
    if (value.length < 1) {
      return 'Post cannot be empty';
    } else
      return null;
  }

  void onSavedMessage(String value) {
    this.message = value;
  }

  void sendMessage() async {
    if (!_state.formKey.currentState.validate()) {
      return;
    }
    _state.formKey.currentState.save();
    try {
      var m = Message(
        createdAt: DateTime.now(),
        createdBy: _state.user.uid,
        text: message,
      );
      await FireBaseController.sendGroupChatMessage(
          sender: _state.user, m: m, g: _state.groupChat);
      _state.render(() => _state.messages.add(m));
      FocusScope.of(_state.context).unfocus();
      _state.formKey.currentState.reset();
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error sending message, try again later',
        content: e.toString(),
      );
    }
  }

  void addMembers() async {
    try {
      await Navigator.pushNamed(_state.context, FriendsListScreen.routeName,
          arguments: {
            'friends': _state.friends,
            'user': _state.user,
            'groupChat': _state.groupChat,
            'groupChatAdd': true
          });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Add member screen error',
        content: e.toString(),
      );
    }
  }
}
