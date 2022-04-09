import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import '../models/UserModel.dart';
import '../screens/tabs_screen.dart';
import '../screens/auth_screen.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class LandingScreen extends StatelessWidget {
  static const routeName = '/landing';

  Future<bool> isSignedIn(BuildContext context) async {
    AuthUser res;
    AuthUserAttribute email;
    try {
      res = await Amplify.Auth.getCurrentUser();
      var res2 = await Amplify.Auth.fetchUserAttributes();
      email = res2.firstWhere((element) => element.userAttributeKey.compareTo(CognitoUserAttributeKey.email) == 0);
      print(res);
    } catch (e) {
      print(e);
      return false;
    }
    UserModel? model = await UsersStorageProxy().getUser(email.value);
    if (model != null) Provider.of<User>(context, listen: false).userFromModel(model);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isSignedIn(context),
        builder: (ctx, AsyncSnapshot<bool> snapshot) {
          final appUser = context.watch<User>().isSignedIn;
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!)
              return TabsScreen();
            else if (appUser)
              return TabsScreen();
            else
              return AuthScreen();
          } else
            return SplashScreen(AuthScreen());
        });
  }
}
