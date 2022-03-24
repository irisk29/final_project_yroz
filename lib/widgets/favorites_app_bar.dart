import 'package:flutter/material.dart';

class FavoritesAppBar {
  AppBar build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: deviceSize.height * 0.1,
      title: Text(
        "Favorites",
        style: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
