import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import '../screens/tabs_screen.dart';
import '../screens/auth_screen.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class LandingScreen extends StatelessWidget {
  static const routeName = '/landing';

  Future<bool> isSignedIn() async {
    try {
      AuthUser res = await Amplify.Auth.getCurrentUser();
      print(res);
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final appUser = context.watch<User>().isSignedIn;
    return appUser ? TabsScreen() : AuthScreen();
  }
}
