import 'dart:io';

import 'package:final_project_yroz/screens/account_screen.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:f_logs/f_logs.dart';
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedBackScreen extends StatefulWidget {
  static const routeName = '/feedback';

  late String userEmail;

  @override
  _FeedBackScreen createState() => _FeedBackScreen();
}

class _FeedBackScreen extends State<FeedBackScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  late List<Tuple2<int, int>> _ratings;
  List<String> questions = [
    "The app is user friendly",
    "The app did not crash",
    "The app responds fast",
    "The app's design"
  ];

  @override
  void didChangeDependencies() {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    widget.userEmail = routeArgs['email'] as String;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _ratings = [];
  }

  Future<void> sendEmail() async {
    String finalText = "";
    Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();

    for (Tuple2<int, int> item in _ratings) {
      finalText += "Question: ${questions[item.item1]}\nRating: ${item.item2}\n\n";
    }
    String freeText = _textEditingController.text;
    if (freeText.isNotEmpty) {
      finalText += "More information from the user: $freeText";
    }

    String companyEmail = secret.COMPANY_EMAIL;
    String subject = "FeedBack From User ${widget.userEmail}";
    print(companyEmail);
    final MailOptions mailOptions =
        MailOptions(body: finalText, subject: subject, recipients: [companyEmail], isHTML: false);

    await FlutterMailer.send(mailOptions);

    FLog.info(text: "Sending feedback email");

    //android -> isAppInstalled will return false in IOS
    const GMAIL_SCHEMA = 'com.google.android.gm';
    final bool gmailinstalled = await FlutterMailer.isAppInstalled(GMAIL_SCHEMA);
    print("gmail: $gmailinstalled");
    if (gmailinstalled) {
      final MailerResponse response = await FlutterMailer.send(mailOptions);
      if (response == MailerResponse.android) {
        SnackBar snackBar = SnackBar(
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          behavior: SnackBarBehavior.floating,
          content: const Text('Mail sent successfully', textAlign: TextAlign.center),
          width: MediaQuery.of(context).size.width * 0.5,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    //IOS
    final bool canSend = await FlutterMailer.canSendMail();
    print("can send: $canSend");
    if (!canSend && Platform.isIOS) {
      final url = "mailto:$companyEmail?subject=$subject&body=$finalText";
      if (await canLaunch(url)) {
        await launch(url);
        SnackBar snackBar = SnackBar(
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          behavior: SnackBarBehavior.floating,
          content: const Text('Mail sent successfully', textAlign: TextAlign.center),
          width: MediaQuery.of(context).size.width * 0.5,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Yroz Feedback'),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: deviceSize.height * 0.05,
              ),
              Text("Please rate the following:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(
                height: deviceSize.height * 0.05,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: deviceSize.width * 0.03),
                    child: Text("The app is user friendly"),
                  ),
                  _ratingBar(0),
                ],
              ),
              SizedBox(
                height: deviceSize.height * 0.05,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: deviceSize.width * 0.03),
                    child: Text("The app did not crash"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: deviceSize.width * 0.03),
                    child: _ratingBar(1),
                  ),
                ],
              ),
              SizedBox(
                height: deviceSize.height * 0.05,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: deviceSize.width * 0.03),
                    child: Text("The app responds fast"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: deviceSize.width * 0.025),
                    child: _ratingBar(2),
                  ),
                ],
              ),
              SizedBox(
                height: deviceSize.height * 0.05,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: deviceSize.width * 0.03),
                    child: Text("The app's design"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: deviceSize.width * 0.11),
                    child: _ratingBar(3),
                  ),
                ],
              ),
              SizedBox(
                height: deviceSize.height * 0.05,
              ),
              Container(
                width: deviceSize.width * 0.95,
                child: TextField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: 'Please tell us more',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: deviceSize.height * 0.05,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  primary: Theme.of(context).primaryColor,
                ),
                child: Container(
                  margin: EdgeInsets.all(deviceSize.width * 0.025),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                onPressed: () async {
                  if (_ratings.isEmpty && _textEditingController.text.isEmpty) {
                    SnackBar snackBar = SnackBar(
                      duration: Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      behavior: SnackBarBehavior.floating,
                      content: const Text('Please fill at least one field', textAlign: TextAlign.center),
                      width: MediaQuery.of(context).size.width * 0.5,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }
                  print("submit");
                  print(_ratings);
                  print(_textEditingController.text);
                  await sendEmail();
                  Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratingBar(int questionIndex) {
    return RatingBar.builder(
      direction: Axis.horizontal,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return Icon(
              Icons.sentiment_very_dissatisfied,
              color: Colors.red,
            );
          case 1:
            return Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.redAccent,
            );
          case 2:
            return Icon(
              Icons.sentiment_neutral,
              color: Colors.amber,
            );
          case 3:
            return Icon(
              Icons.sentiment_satisfied,
              color: Colors.lightGreen,
            );
          case 4:
            return Icon(
              Icons.sentiment_very_satisfied,
              color: Colors.green,
            );
          default:
            return Container();
        }
      },
      onRatingUpdate: (rating) {
        setState(() {
          _ratings.removeWhere((element) => element.item1 == questionIndex);
          _ratings.add(Tuple2(questionIndex, rating.toInt()));
        });
      },
      updateOnDrag: true,
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
