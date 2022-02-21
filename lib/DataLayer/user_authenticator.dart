import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:project_demo/DataLayer/UsersStorageProxy.dart';
import 'package:project_demo/models/ModelProvider.dart';

class UserAuthenticator {
  static final UserAuthenticator _singleton = UserAuthenticator._internal();
  String _currentUserId = "";
  factory UserAuthenticator() {
    return _singleton;
  }

  UserAuthenticator._internal();

  Future<UserModel> signIn(AuthProvider authProvider) async {
    UserModel currUser = null;
    try {
      await Amplify.Auth.signInWithWebUI(provider: authProvider);
      var res = await Amplify.Auth.fetchUserAttributes();
      var email, name, picture;
      for (var element in res) {
        if (element.userAttributeKey == "given_name") name = element.value;
        if (element.userAttributeKey == "email") email = element.value;
        if (element.userAttributeKey == "picture") picture = element.value;
        print('key: ${element.userAttributeKey}; value: ${element.value}');
      }
      currUser = await UsersStorageProxy().createUser(email, name, picture);
      _currentUserId = email;
    } catch (e) {
      print(e);
    }
    return currUser;
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
