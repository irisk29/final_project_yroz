import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:final_project_yroz/models/UserModel.dart';

import 'UsersStorageProxy.dart';

class UserAuthenticator {
  static final UserAuthenticator _singleton = UserAuthenticator._internal();
  String _currentUserId = "";
  factory UserAuthenticator() {
    return _singleton;
  }

  UserAuthenticator._internal();

  Future<UserModel> signIn(AuthProvider authProvider) async {
    try {
      await Amplify.Auth.signInWithWebUI(provider: authProvider);
      var res = await Amplify.Auth.fetchUserAttributes();
      var email, name, picture;
      for (var element in res) {
        if (element.userAttributeKey.key == "given_name") name = element.value;
        if (element.userAttributeKey.key == "email") email = element.value;
        if (element.userAttributeKey.key == "picture") picture = element.value;
        print('key: ${element.userAttributeKey}; value: ${element.value}');
      }
      UserModel? currUser =
          await UsersStorageProxy().createUser(email!, name!, picture!);
      _currentUserId = email;
      return currUser;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      print(e.message);
      return true;
    }
    return false; //false indicating the user is not signed in anymore
  }

  String getCurrentUserId() {
    return _currentUserId;
  }
}
