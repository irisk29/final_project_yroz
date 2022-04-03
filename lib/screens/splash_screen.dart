import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  Widget nextScreen;

  SplashScreen(this.nextScreen);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return AnimatedSplashScreen(
      splash: 'assets/icon/icon.png',
      animationDuration: Duration(milliseconds: 1500),
      duration: 2000,
      nextScreen: nextScreen,
      splashTransition: SplashTransition.fadeTransition,
      splashIconSize: 0.15 * (deviceSize.width + deviceSize.height),
      backgroundColor: Color.fromRGBO(255, 179, 179, 1),
    );
  }
}
