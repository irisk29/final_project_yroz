import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:final_project_yroz/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../amplifyconfiguration.dart';
import '../models/ModelProvider.dart';

class LoadingSplashScreen extends StatefulWidget {
  static const routeName = '/loading-splash';

  @override
  State<LoadingSplashScreen> createState() => _LoadingSplashScreenState();
}

class _LoadingSplashScreenState extends State<LoadingSplashScreen> with TickerProviderStateMixin {
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
    ticker.timeout(Duration(seconds: 20), onTimeout: () {
      FLog.error(text: "Timeout occurd in ticker");
      Navigator.of(context).pushReplacementNamed(LandingScreen.routeName);
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await _configureAmplify();
      await refreshLocalData();
      const MODEL_COUNT = 8;
      var currentModelIndex = 0;
      var timers = [];
      Stopwatch stopwatch = new Stopwatch()..start();
      Amplify.Hub.listen([HubChannel.DataStore], (msg) {
        if (msg.eventName == 'modelSynced') {
          currentModelIndex++;
          timers.add(stopwatch.elapsed);
          var avgTime = timers.reduce((value, element) => value + element) ~/ timers.length;
          var duration = MODEL_COUNT - currentModelIndex > 0 ? avgTime * (MODEL_COUNT - currentModelIndex) : avgTime;
          duration = 1 - controller.value > 0 ? duration * (1 / (1 - controller.value)) : duration;
          controller.duration = duration;
          if (controller.isAnimating) ticker = controller.forward();
          stopwatch = new Stopwatch()..start();
        } else if (msg.eventName == 'ready') {
          FLog.info(text: "AWS Amplify is ready");
          ticker.then((value) => Navigator.pushReplacementNamed(context, LandingScreen.routeName));
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
      FLog.error(text: "Amplify was already configured. Was the app restarted?");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 179, 179),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: constraints.maxHeight * 0.15, child: Image.asset('assets/icon/icon.png')),
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
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
