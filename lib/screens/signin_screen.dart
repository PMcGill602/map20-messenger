import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/screens/home_screen.dart';
import 'package:messengerapp/screens/signup_screen.dart';
import 'package:messengerapp/screens/views/mydialog.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Image.asset('assets/images/letter.png'),
                  Positioned(
                    top: 50.0,
                    left: 0,
                    child: Text(
                      'Messenger',
                      style: TextStyle(color: Colors.red, fontSize: 25.0),
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validatorEmail,
                onSaved: con.onSavedEmail,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                obscureText: true,
                autocorrect: false,
                validator: con.validatorPassword,
                onSaved: con.onSavedPassword,
              ),
              RaisedButton(
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                color: Colors.red,
                onPressed: con.signIn,
              ),
              SizedBox(
                height: 30.0,
              ),
              FlatButton(
                  onPressed: con.signUp,
                  child: Text(
                    'Create an account.',
                    style: TextStyle(fontSize: 15.0),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignInState _state;
  _Controller(this._state);
  String email;
  String password;

  signIn() async {
    if (!_state.formKey.currentState.validate()) {
      return;
    }
    _state.formKey.currentState.save();
    MyDialog.circularProgressStart(_state.context);
    User user;
    try {
      user = await FireBaseController.signIn(email, password);
    } catch (e) {
      MyDialog.circularProgressEnd(_state.context);
      MyDialog.info(
        context: _state.context,
        title: 'Sign In Error',
        content: e.message ?? e.toString(),
      );
      return;
    }
    MyDialog.circularProgressEnd(_state.context);
    Navigator.pushReplacementNamed(_state.context, HomeScreen.routeName,
        arguments: {'user': user});
  }

  String validatorEmail(String value) {
    if (value == null || !value.contains('@') || !value.contains('.')) {
      return 'Invalid email address';
    } else {
      return null;
    }
  }

  void onSavedEmail(String value) {
    email = value;
  }

  String validatorPassword(String value) {
    if (value == null || value.length < 6) {
      return 'Password must have minimum 6 characters';
    } else {
      return null;
    }
  }

  void onSavedPassword(String value) {
    password = value;
  }

  void signUp() async {
    Navigator.pushNamed(_state.context, SignUpScreen.routeName);
  }
}
