import 'package:flutter/material.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/screens/views/mydialog.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signInScreen/signUpScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
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
      appBar: AppBar(title: Text('Create an account')),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(hintText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validatorEmail,
                onSaved: con.onSavedEmail,
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Password'),
                obscureText: true,
                autocorrect: false,
                validator: con.validatorPassword,
                onSaved: con.onSavedPassword,
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Display name'),
                autocorrect: false,
                validator: con.validatorDisplayName,
                onSaved: con.onSavedDisplayName,
              ),
              RaisedButton(
                child: Text(
                  'Create',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                color: Colors.red,
                onPressed: con.signUp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignUpState _state;
  _Controller(this._state);
  String email;
  String password;
  String displayName;

  void signUp() async {
    if (!_state.formKey.currentState.validate()) {
      return;
    }
    _state.formKey.currentState.save();
    try {
      await FireBaseController.signUp(email, password, displayName);
      MyDialog.info(
        context: _state.context,
        title: 'Successfully created',
        content: 'Your account has been created, you may now sign in',
      );
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error',
        content: e.message ?? e.toString(),
      );
    }
  }

  String validatorEmail(String value) {
    if (value.contains('@') && value.contains('.')) {
      return null;
    } else
      return 'Invalid email';
  }

  void onSavedEmail(String value) {
    this.email = value;
  }

  String validatorPassword(String value) {
    if (value.length < 6) {
      return 'Minimum 6 characters';
    } else
      return null;
  }

  void onSavedPassword(String value) {
    this.password = value;
  }

  String validatorDisplayName(String value) {
    if (value.length < 3) {
      return 'Minimum 3 characters';
    } else
      return null;
  }

  void onSavedDisplayName(String value) {
    this.displayName = value;
  }
}
