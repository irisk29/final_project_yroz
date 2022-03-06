import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SafeArea(child: MyApp()),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> sendRequest() async {
    var url = 'http://127.0.0.1:5000/create_payment_method&accountId=33612345678&cardNumber=1111111&cardDate=21/1';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    print(json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Example app'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            child: const Text('Select Categories'),
            onPressed: () => sendRequest(),
          ),
        ],
      ),
    );
  }
}