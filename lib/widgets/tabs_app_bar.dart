import 'package:flutter/material.dart';

class TabsAppBar {
  final String title;

  TabsAppBar(this.title);

  AppBar build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: deviceSize.height * 0.1,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 23,
          ),
        ),
      ),
    );
  }
}
