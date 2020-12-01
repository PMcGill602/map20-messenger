import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/chat.dart';
import 'package:messengerapp/model/message.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/views/mydialog.dart';
import 'package:flutter_smart_reply/flutter_smart_reply.dart';

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
  List<String> smartReplyReplies = List.empty();
  bool isSelf = true;
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
                itemBuilder: (BuildContext context, int index) => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: messages[index].createdBy == user.uid
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: ListTile(
                        title: Text(messages[index].text),
                        subtitle: Text(messages[index].createdAt.toString()),
                      ),
                    ),
                  ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text('Send'),
                  onPressed: con.sendMessage,
                ),
                SizedBox(width: 20),
                RaisedButton(
                  child: Text('Smart replies'),
                  onPressed: messages.length == 0 ? null : con.smartReplies,
                ),
              ],
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
        displayName: _state.user.displayName,
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

  void smartReplies() async {
    List<TextMessage> smartReplyMessages = [];
    for (var message in _state.messages) {
      smartReplyMessages.add(message.createdBy == _state.user.uid
          ? TextMessage.createForLocalUser(
              message.text, message.createdAt.millisecondsSinceEpoch)
          : TextMessage.createForRemoteUser(
              message.text, message.createdAt.millisecondsSinceEpoch));
    }

    try {
      _state.smartReplyReplies =
          await FlutterSmartReply.getSmartReplies(smartReplyMessages);
      showDialog(
        barrierDismissible: false,
        context: _state.context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: _state.smartReplyReplies.length == 0
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Text('No smart replies'),
                      ),
                      RaisedButton(
                        child: Text('Ok'),
                        onPressed: () => Navigator.of(_state.context).pop(),
                      ),
                    ],
                  )
                : Container(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          height: 150,
                          width: 150,
                          child: ListView.builder(
                            itemCount: _state.smartReplyReplies.length,
                            itemBuilder: (BuildContext context, int index) =>
                                Container(
                              child: RaisedButton(
                                child: Text(
                                    _state.smartReplyReplies[index].toString()),
                                onPressed: () async {
                                  var m = Message(
                                    createdAt: DateTime.now(),
                                    createdBy: _state.user.uid,
                                    displayName: _state.user.displayName,
                                    text: _state.smartReplyReplies[index]
                                        .toString(),
                                  );
                                  await FireBaseController.sendMessage(
                                      sender: _state.user,
                                      receiver: _state.friend,
                                      m: m,
                                      c: _state.chat);

                                  Navigator.of(_state.context).pop();
                                  _state.render(() => _state.messages.add(m));
                                },
                              ),
                            ),
                          ),
                        ),
                        RaisedButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(_state.context).pop(),
                        ),
                      ],
                    ),
                  ),
          );
        },
      );
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error getting smart replies, try again later',
        content: e.toString(),
      );
    }
  }
}
