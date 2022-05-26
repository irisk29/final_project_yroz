import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:final_project_yroz/main.dart';
import 'package:final_project_yroz/screens/auth_screen.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:provider/provider.dart';

import '../LogicLayer/User.dart';
import '../amplifyconfiguration.dart';
import '../models/ModelProvider.dart';

class LoadingSplashScreen extends StatefulWidget {
  static const routeName = '/loading-splash';

  @override
  State<LoadingSplashScreen> createState() => _LoadingSplashScreenState();
}

class _LoadingSplashScreenState extends State<LoadingSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..addListener(() {
        setState(() {});
      });
    TickerFuture ticker = controller.forward();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await _configureAmplify();
      await refreshLocalData();
      const MODEL_COUNT = 8;
      var currentModelIndex = 0;
      var timers = [];
      Stopwatch stopwatch = new Stopwatch()..start();
      Amplify.Hub.listen([HubChannel.DataStore], (msg) async {
        if (msg.eventName == 'modelSynced') {
          currentModelIndex++;
          timers.add(stopwatch.elapsed);
          var avgTime = timers.reduce((value, element) => value + element) ~/
              timers.length;
          var duration = MODEL_COUNT - currentModelIndex > 0
              ? avgTime * (MODEL_COUNT - currentModelIndex)
              : avgTime;
          duration = 1 - controller.value > 0
              ? duration * (1 / (1 - controller.value))
              : duration;
          controller.duration = duration;
          ticker = controller.forward();
          stopwatch = new Stopwatch()..start();
        } else if (msg.eventName == 'ready') {
          FLog.info(text: "AWS Amplify is ready");
          final isUserAlreadySignedIn = await isSignedIn();
          Secret secret =
              await SecretLoader(secretPath: "assets/secrets.json").load();
          MyApp.CASH_BACK_PRECENTEGE = secret.CASH_BACK_PRECENTEGE;
          ticker.whenCompleteOrCancel(() => Navigator.pushReplacementNamed(
              context,
              isUserAlreadySignedIn
                  ? TabsScreen.routeName
                  : AuthScreen.routeName));
        }
      });
    });
  }

  Future<void> refreshLocalData() async {
    //get fresh information from cloud everytime the app starts
    try {
      await Amplify.DataStore.clear();
    } catch (error) {
      print('Error stopping DataStore: $error');
    }

    try {
      await Amplify.DataStore.start();
    } catch (error) {
      print('Error starting DataStore: $error');
    }
  }

  Future<void> _configureAmplify() async {
    if (!mounted) return;

    if (Amplify.isConfigured) return;
    Amplify.addPlugin(AmplifyAuthCognito());
    Amplify.addPlugin(AmplifyStorageS3());
    Amplify.addPlugin(AmplifyDataStore(modelProvider: ModelProvider.instance));
    Amplify.addPlugin(AmplifyAPI());

    // Amplify can only be configured once.
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      FLog.error(
          text: "Amplify was already configured. Was the app restarted?");
    }
  }

  Future<bool> isSignedIn() async {
    AuthUserAttribute email;
    try {
      await Amplify.Auth.getCurrentUser();
      var res2 = await Amplify.Auth.fetchUserAttributes();
      email = res2.firstWhere((element) =>
          element.userAttributeKey.compareTo(CognitoUserAttributeKey.email) ==
          0);
    } catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return false;
    }
    UserModel? model = await UsersStorageProxy().fetchFullUser(email.value);
    print("isLoggedIn: ${model != null && model.isLoggedIn}");
    if (model != null)
      await Provider.of<User>(context, listen: false).userFromModel(model);
    if (model != null && model.isLoggedIn) {
      UserAuthenticator().setCurrentUserId(model.email);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 255, 179, 179),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: constraints.maxHeight * 0.19,
                        child: Image.asset('assets/icon/icon.png')),
                  ],
                ),
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: constraints.maxHeight * 0.1,
                    left: constraints.maxWidth * 0.075,
                    right: constraints.maxWidth * 0.075,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white70,
                      value: controller.value,
                      minHeight: constraints.maxHeight * 0.05,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
