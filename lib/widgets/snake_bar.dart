import 'package:final_project_yroz/LogicLayer/ConnectivityProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

SnackBar showSnackBar(BuildContext context, String content) {
  final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;

  String msg = content;

  if (!isOnline) {
    msg +=
        " BUT be aware you have no internet connection, your acction will be updated to other users once you restore your internet.";
  }

  SnackBar snackBar = SnackBar(
    duration: Duration(seconds: 3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    behavior: SnackBarBehavior.floating,
    content: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
    width: MediaQuery.of(context).size.width * 0.75,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  Navigator.of(context).pop();

  return snackBar;
}
