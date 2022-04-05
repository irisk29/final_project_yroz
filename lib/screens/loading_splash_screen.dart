import 'dart:async';

import 'package:f_logs/model/flog/flog.dart';
import 'package:final_project_yroz/screens/landing_screen.dart';
import 'package:flutter/material.dart';

import 'package:amplify_flutter/amplify_flutter.dart';

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

    var hubSubscription = Amplify.Hub.listen([HubChannel.DataStore], (msg) {
      if (msg.eventName == 'ready') {
        FLog.info(text: "AWS Amplify is ready");
        print("READY!!");
      }
    });

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..addListener(() {
        setState(() {});
      });
    controller.forward();
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
                  Container(
                      height: constraints.maxHeight * 0.15,
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
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white70,
                  value: controller.value,
                  minHeight: constraints.maxHeight * 0.05,
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
