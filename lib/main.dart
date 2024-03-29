import 'package:flutter/material.dart';
import 'package:messengerapp/screens/friendrequests_screen.dart';
import 'package:messengerapp/screens/friendslist_screen.dart';
import 'package:messengerapp/screens/groupchatdetailed_screen.dart';
import 'package:messengerapp/screens/groupchats_screen.dart';
import 'package:messengerapp/screens/home_screen.dart';
import 'package:messengerapp/screens/messages_screen.dart';
import 'package:messengerapp/screens/post_screen.dart';
import 'package:messengerapp/screens/profile_screen.dart';
import 'package:messengerapp/screens/profileedit_screen.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        secondaryHeaderColor: Colors.yellow,
        buttonColor: Colors.yellow[800],
        accentColor: Colors.yellow[800],
        
      ),
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        SearchScreen.routeName: (context) => SearchScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        ProfileEditScreen.routeName: (context) => ProfileEditScreen(),
        FriendRequestsScreen.routeName: (context) => FriendRequestsScreen(),
        PostScreen.routeName: (context) => PostScreen(),
        FriendsListScreen.routeName: (context) => FriendsListScreen(),
        MessagesScreen.routeName: (context) => MessagesScreen(),
        GroupChatsScreen.routeName: (context) => GroupChatsScreen(),
        GroupChatDetailedScreen.routeName: (context) => GroupChatDetailedScreen(),
      },
    );
  }

}