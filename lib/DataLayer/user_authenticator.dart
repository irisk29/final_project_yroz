import 'dart:async';
import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:f_logs/f_logs.dart';
import 'package:final_project_yroz/models/UserModel.dart';
import 'package:tuple/tuple.dart';

import 'UsersStorageProxy.dart';

class UserAuthenticator {
  static final UserAuthenticator _singleton = UserAuthenticator._internal();
  String _currentUserId = "";
  factory UserAuthenticator() {
    return _singleton;
  }

  UserAuthenticator._internal();

  Future<Tuple2<UserModel?, bool>> signIn(AuthProvider authProvider) async {
    try {
      var res1 = await Amplify.Auth.signInWithWebUI(provider: authProvider);
      if (res1.isSignedIn) {
        print("**** the user is finally signed in!! ***");
        var res = await Amplify.Auth.fetchUserAttributes();
        var email, name, picture;
        for (var element in res) {
          if (element.userAttributeKey.key == "given_name")
            name = element.value;
          if (element.userAttributeKey.key == "email") email = element.value;
          if (element.userAttributeKey.key == "picture")
            picture = element.value;
          print('key: ${element.userAttributeKey}; value: ${element.value}');
        }
        if (authProvider == AuthProvider.facebook) {
          var map = jsonDecode(picture);
          picture = map["data"]["url"];
        }
        Tuple2<UserModel?, bool> currUser =
            await UsersStorageProxy().createUser(email, name, picture);
        _currentUserId = email;
        return currUser;
      } else
        return new Tuple2(null, true);
    } catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      if (e.toString().contains("There is already a user which is signed in"))
        return new Tuple2(null, true);
      return new Tuple2(null, false);
    }
  }

  Future<bool> signOut() async {
    try {
      await UsersStorageProxy().logoutUser();
      await Amplify.Auth.signOut(options: SignOutOptions(globalSignOut: true));
    } on AuthException catch (e) {
      print(e.message);
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return true;
    }
    return false; //false indicating the user is not signed in anymore
  }

  String getCurrentUserId() {
    return _currentUserId;
  }

  void setCurrentUserId(String email) {
    this._currentUserId = email;
  }
}
