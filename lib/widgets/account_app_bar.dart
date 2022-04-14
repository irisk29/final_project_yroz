import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountAppBar {
  AppBar build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final user = Provider.of<User>(context, listen: false);

    return AppBar(
      automaticallyImplyLeading: false,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "My Account",
          style: const TextStyle(
            fontSize: 23,
          ),
        ),
      ),
      toolbarHeight: deviceSize.height * 0.1,
      actions: [
        IconButton(
            onPressed: () => Navigator.pushNamed(
                  context,
                  FeedBackScreen.routeName,
                  arguments: {'email': user.email},
                ),
            icon: Icon(Icons.feedback_outlined))
      ],
    );
  }
}
