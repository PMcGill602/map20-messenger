import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/post.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/views/mydialog.dart';

class PostScreen extends StatefulWidget {
  static const routeName = '/signInScreen/homeScreen/profileScreen/postScreen';
  @override
  State<StatefulWidget> createState() {
    return _PostState();
  }
}

class _PostState extends State<PostScreen> {
  _Controller con;
  StoredUserInfo user;
  List<Post> posts;
  var formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    user ??= arg['user'];
    posts ??= arg['posts'];
    return Scaffold(
      appBar: AppBar(
        title: Text("New Post"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                ),
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                validator: con.validatorPost,
                onSaved: con.onSavedPost,
              ),
              RaisedButton(
                child: Text('Post!'),
                onPressed: con.makePost,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _PostState _state;
  _Controller(this._state);
  String post;

  String validatorPost(String value) {
    if (value.length < 1) {
      return 'Post cannot be empty';
    } else return null;
  }

  void onSavedPost(String value) {
    this.post = value;
  }

  void makePost() async{
    if (!_state.formKey.currentState.validate()) {
      return;
    }
    _state.formKey.currentState.save();
    try {
      var p = Post(
        message: post,
        createdBy: _state.user.uid,
      );
      await FireBaseController.makePost(p);
      _state.posts.add(p);
      Navigator.pop(_state.context);
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error making post, try again later',
        content: e.toString(),
      );
    }
  }
}
