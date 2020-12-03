import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messengerapp/controller/firebasecontroller.dart';
import 'package:messengerapp/model/storeduserinfo.dart';
import 'package:messengerapp/screens/views/mydialog.dart';
import 'package:messengerapp/screens/views/myimageview.dart';

class ProfileEditScreen extends StatefulWidget {
  static const routeName =
      '/signInScreen/homeScreen/profileScreen/profileEditScreen';
  @override
  State<StatefulWidget> createState() {
    return _ProfileEditState();
  }
}

class _ProfileEditState extends State<ProfileEditScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  StoredUserInfo user;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args['user'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: con.save)],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(
                height: 20.0,
              ),
              Stack(children: [
                Container(
                  width: 150,
                  child: ClipOval(
                    child: con.imageFile == null
                        ? MyImageView.network(
                            imageUrl: user.photoUrl, context: context)
                        : Image.file(
                            con.imageFile,
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    child: PopupMenuButton<String>(
                        onSelected: con.getPicture,
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                value: 'camera',
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.photo_camera),
                                    Text('Camera'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'gallery',
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.photo_library),
                                    Text('Gallery'),
                                  ],
                                ),
                              ),
                            ]),
                  ),
                )
              ]),
              TextFormField(
                style: TextStyle(fontSize: 14.0),
                decoration: InputDecoration(
                  hintText: 'Display Name',
                ),
                initialValue: user.displayName,
                validator: con.validatorDisplayName,
                onSaved: con.onSavedDisplayName,
              ),
              TextFormField(
                style: TextStyle(fontSize: 14.0),
                decoration: InputDecoration(
                  hintText: 'Biography',
                ),
                initialValue: user.biography,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                validator: con.validatorBiography,
                onSaved: con.onSavedBiography,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _ProfileEditState _state;
  _Controller(this._state);
  File imageFile;

  String validatorDisplayName(String value) {
    if (value.length < 3) {
      return 'Minimum 3 characters';
    } else
      return null;
  }

  void onSavedDisplayName(String value) {
    _state.user.displayName = value;
  }

  String validatorBiography(String value) {
    return null;
  }

  void onSavedBiography(String value) {
    _state.user.biography = value;
  }

  void getPicture(String src) async {
    try {
      PickedFile _imageFile;
      if (src == 'camera') {
        _imageFile = await ImagePicker().getImage(source: ImageSource.camera);
      } else {
        _imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
      }
      _state.render(() {
        imageFile = File(_imageFile.path);
      });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error getting picture',
        content: e.message ?? e.toString(),
      );
    }
  }

  void save() async {
    if (!_state.formKey.currentState.validate()) {
      return;
    }
    _state.formKey.currentState.save();
    try {
      String url = await FireBaseController.saveProfile(user: _state.user, image: imageFile);
      _state.user.photoUrl = url;
      Navigator.pop(_state.context, _state.user);
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error saving profile',
        content: e.message ?? e.toString(),
      );
    }
  }
}
