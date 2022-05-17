import 'dart:io';

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
  late bool isStoreOwner;

  @override
  _FeedBackScreen createState() => _FeedBackScreen();
}

class _FeedBackScreen extends State<FeedBackScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  late List<Tuple2<int, int>> _ratings;
  List<String> questions = [
    "User Friendly",
    "Working Properly & Stability",
    "Responds Time",
    "Design - Look & Feel",
    "Improve My Business Income"
  ];
  var _formChanged;
  var _showError = false;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    widget.userEmail = routeArgs['email'] as String;
    widget.isStoreOwner = routeArgs['isStoreOwner'] as bool;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _ratings = [];
    _formChanged = false;
  }

  Future<void> sendEmail() async {
    setState(() => _isLoading = true);

    String finalText = "";
    Secret secret =
        await SecretLoader(secretPath: "assets/secrets.json").load();

    for (Tuple2<int, int> item in _ratings) {
      finalText +=
          "Question: ${questions[item.item1]}\nRating: ${item.item2}\n\n";
    }
    String freeText = _textEditingController.text;
    if (freeText.isNotEmpty) {
      finalText += "More information from the user: $freeText";
    }

    String companyEmail = secret.COMPANY_EMAIL;
    String subject = "FeedBack From User ${widget.userEmail}";
    print(companyEmail);
    final MailOptions mailOptions = MailOptions(
        body: finalText,
        subject: subject,
        recipients: [companyEmail],
        isHTML: false);

    await FlutterMailer.send(mailOptions);

    FLog.info(text: "Sending feedback email");

    //android -> isAppInstalled will return false in IOS
    const GMAIL_SCHEMA = 'com.google.android.gm';
    final bool gmailinstalled =
        await FlutterMailer.isAppInstalled(GMAIL_SCHEMA);
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
          content:
              const Text('Mail sent successfully', textAlign: TextAlign.center),
          width: MediaQuery.of(context).size.width * 0.5,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
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
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            content: const Text('Thank you for your feedback!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87)),
            width: MediaQuery.of(context).size.width * 0.75,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          throw 'Could not launch $url';
        }
      }
    }

    Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
    setState(() => _isLoading = false);
  }

  void _exitWithoutSavingDialog() {
    if (_formChanged) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Are your sure?'),
          content: Text("You are about to exit without saving your changes."),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: _isLoading
              ? Container()
              : IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => _exitWithoutSavingDialog(),
                ),
          toolbarHeight: deviceSize.height * 0.1,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Rate Us',
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
          ),
        ),
        body: _isLoading
            ? Align(
                alignment: Alignment.center,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Center(
                      child: SizedBox(
                        height: deviceSize.height * 0.8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Container(
                              width: deviceSize.width * 0.6,
                              child: Text(
                                  "We are sending your feedback to us, it might take a few seconds...",
                                  textAlign: TextAlign.center),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  child: SizedBox(
                    height: deviceSize.height * 0.85,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: deviceSize.width * 0.05,
                          right: deviceSize.width * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text("Please Rate the Following Aspects:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: deviceSize.height * 0.015),
                                child: Text(questions[0],
                                    textAlign: TextAlign.left),
                              ),
                              Center(child: _ratingBar(0)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: deviceSize.height * 0.015),
                                child: Text(questions[1],
                                    textAlign: TextAlign.left),
                              ),
                              Center(child: _ratingBar(1)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: deviceSize.height * 0.015),
                                child: Text(questions[2],
                                    textAlign: TextAlign.left),
                              ),
                              Center(child: _ratingBar(2)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: deviceSize.height * 0.015),
                                child: Text(questions[3],
                                    textAlign: TextAlign.left),
                              ),
                              Center(child: _ratingBar(3)),
                            ],
                          ),
                          if (widget.isStoreOwner)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: deviceSize.height * 0.015),
                                  child: Text(questions[4],
                                      textAlign: TextAlign.left),
                                ),
                                Center(child: _ratingBar(4)),
                              ],
                            ),
                          if (_showError)
                            Text(
                              "Please fill at least one field",
                              style: TextStyle(
                                  color: Theme.of(context).errorColor),
                            ),
                          TextField(
                            controller: _textEditingController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Please tell us more',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                            ),
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
                              if (_ratings.isEmpty &&
                                  _textEditingController.text.isEmpty) {
                                setState(() => _showError = true);
                                return;
                              }
                              await sendEmail();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _ratingBar(int questionIndex) {
    return RatingBar.builder(
      direction: Axis.horizontal,
      itemSize: MediaQuery.of(context).size.width * 0.08,
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
          _formChanged = true;
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
