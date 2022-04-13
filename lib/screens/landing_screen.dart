import 'dart:async';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:f_logs/f_logs.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import '../models/UserModel.dart';
import '../screens/tabs_screen.dart';
import '../screens/auth_screen.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class LandingScreen extends StatefulWidget {
  static const routeName = '/landing';

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late bool? isUserAlreadySignedIn = null;

  @override
  void initState() {
    super.initState();
    isSignedIn().then((data) {
      setState(() {
        isUserAlreadySignedIn = data;
      });
    }).catchError((e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      Navigator.pop(context, "an error");
    });
  }

  Future<bool> isSignedIn() async {
    AuthUser res;
    AuthUserAttribute email;
    try {
      res = await Amplify.Auth.getCurrentUser();
      var res2 = await Amplify.Auth.fetchUserAttributes();
      email = res2.firstWhere((element) => element.userAttributeKey.compareTo(CognitoUserAttributeKey.email) == 0);
    } catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return false;
    }
    UserModel? model = await UsersStorageProxy().fetchFullUser(email.value);
    print("isLoggedIn: ${model != null && model.isLoggedIn}");
    if (model != null) Provider.of<User>(context, listen: false).userFromModel(model);
    if (model != null && model.isLoggedIn) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    print("is already: $isUserAlreadySignedIn");
    return isUserAlreadySignedIn == null
        ? Center(child: CircularProgressIndicator())
            : !isUserAlreadySignedIn!
                ? AuthScreen()
                : TabsScreen();            
  }
}
