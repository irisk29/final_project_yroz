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
      /*var isAlreadySignedIn = await Amplify.Auth.fetchAuthSession();
      if (isAlreadySignedIn.isSignedIn) {
        return new Tuple2(null, false);
      }*/
      await Amplify.Auth.signInWithWebUI(provider: authProvider);
      var res = await Amplify.Auth.fetchUserAttributes();
      var email, name, picture;
      for (var element in res) {
        if (element.userAttributeKey.key == "given_name") name = element.value;
        if (element.userAttributeKey.key == "email") email = element.value;
        if (element.userAttributeKey.key == "picture") picture = element.value;
        print('key: ${element.userAttributeKey}; value: ${element.value}');
      }

      Tuple2<UserModel?, bool> currUser =
          await UsersStorageProxy().createUser(email, name, picture);
      _currentUserId = email;
      return currUser;
    } catch (e) {
      var res = await signOut();
      print("user signed out $res");
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      throw e;
    }
  }

  Future<bool> signOut() async {
    try {
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
