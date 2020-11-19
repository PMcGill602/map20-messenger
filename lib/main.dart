import 'package:flutter/material.dart';
import 'package:messengerapp/screens/friendrequests_screen.dart';
import 'package:messengerapp/screens/home_screen.dart';
import 'package:messengerapp/screens/profile_screen.dart';
import 'package:messengerapp/screens/search_screen.dart';
import 'package:messengerapp/screens/signin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:messengerapp/screens/signup_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MessengerApp());
}

class MessengerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        SearchScreen.routeName: (context) => SearchScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        FriendRequestsScreen.routeName: (context) => FriendRequestsScreen(),
      },
    );
  }

}