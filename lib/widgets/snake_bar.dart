import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showSnackBar(BuildContext context, String content) {
  SnackBar snackBar = SnackBar(
    duration: Duration(seconds: 3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    behavior: SnackBarBehavior.floating,
    content: Text(content, textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
    width: MediaQuery.of(context).size.width * 0.75,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  Navigator.of(context).pop();
}
