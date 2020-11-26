import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/chat.dart';
import 'package:messengerapp/model/message.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/views/mydialog.dart';

class MessagesScreen extends StatefulWidget {
  static const routeName =
      '/signInScreen/homeScreen/profileScreen/friendsListScreen/messagesScreen';
  @override
  State<StatefulWidget> createState() {
    return _MessagesState();
  }
}

class _MessagesState extends State<MessagesScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  StoredUserInfo user;
  StoredUserInfo friend;
  Chat chat;
  List<Message> messages;
  bool test = false;
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
    friend ??= arg['friend'];
    chat ??= arg['chat'];
    messages ??= arg['messages'];
    return Scaffold(
        appBar: AppBar(
          title: Text('Messages from ${friend.displayName}'),
        ),
        body: Column(
          children: <Widget>[
            Text('Start of message history'),
            Flexible(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  padding: messages[index].createdBy != user.uid ? EdgeInsets.fromLTRB(10, 5, 250, 5) : EdgeInsets.fromLTRB(250, 5, 5, 5),
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
        ));
  }
}

class _Controller {
  _MessagesState _state;
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
      await FireBaseController.sendMessage(
          sender: _state.user, receiver: _state.friend, m: m, c: _state.chat);
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
}
