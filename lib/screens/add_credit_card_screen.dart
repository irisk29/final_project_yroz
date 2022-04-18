import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:final_project_yroz/widgets/credit_card_form.dart' as form;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:final_project_yroz/widgets/credit_card_model.dart' as model;
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/glassmorphism_config.dart';
import 'package:provider/provider.dart';

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';
import '../models/UserModel.dart';

class AddCreditCardScreen extends StatefulWidget {
  static const routeName = '/add-credit-card';

  @override
  State<StatefulWidget> createState() {
    return AddCreditCardScreenState();
  }

  Widget wrapWithMaterial(List<NavigatorObserver> nav, UserModel user) {
    return MaterialApp(
      routes: {
        TabsScreen.routeName: (ctx) => TabsScreen().wrapWithMaterial(nav),
      },
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: User.fromModel(user),
          ),
        ],
        child: this,
      ),
      // This mocked observer will now receive all navigation events
      // that happen in our app.
      //navigatorObservers: nav,
    );
  }
}

class AddCreditCardScreenState extends State<AddCreditCardScreen> {
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late Secret secret;

  var _isLoading = false;
  var _formChanged;

  @override
  void initState() {
    _resetForm();
    _formChanged = false;
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  void _resetForm() {
    cardNumber = '';
    expiryDate = '';
    cardHolderName = '';
    cvvCode = '';
  }

  Future<void> saveCreditCard() async {
    setState(() {
      _isLoading = true;
    });
    secret = await SecretLoader(secretPath: "assets/secrets.json").load();

    final key = encrypt.Key.fromUtf8(secret.KEY);
    final iv = encrypt.IV.fromUtf8(secret.IV);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));

    final encrypted = encrypter.encrypt(cardNumber, iv: iv);
    print(encrypted.base16);
    String num = encrypted.base16.toString();
    final res = await Provider.of<User>(context, listen: false)
        .addCreditCard(num, expiryDate, cvvCode, cardHolderName);

    setState(() {
      _isLoading = false;
    });

    if (res.getTag()) {
      Navigator.of(context).pop(true);
    } else {
      _resetForm();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Credit Card Error'),
          content: Text(res.getMessage()),
          actions: <Widget>[
            FlatButton(
              key: const Key("ok_error"),
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
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
    var deviceSize = MediaQuery.of(context).size;

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
              "New Credit Card",
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      CreditCardWidget(
                        glassmorphismConfig: useGlassMorphism
                            ? Glassmorphism.defaultConfig()
                            : null,
                        cardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        showBackView: isCvvFocused,
                        obscureCardNumber: true,
                        obscureCardCvv: true,
                        isHolderNameVisible: true,
                        cardBgColor: Colors.blue,
                        isSwipeGestureEnabled: true,
                        onCreditCardWidgetChange:
                            (CreditCardBrand creditCardBrand) {},
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              form.CreditCardForm(
                                formKey: formKey,
                                obscureCvv: true,
                                obscureNumber: true,
                                cardNumber: cardNumber,
                                cvvCode: cvvCode,
                                isHolderNameVisible: true,
                                isCardNumberVisible: true,
                                isExpiryDateVisible: true,
                                cardHolderName: cardHolderName,
                                expiryDate: expiryDate,
                                themeColor: Colors.blue,
                                textColor: Colors.black,
                                cardNumberDecoration: InputDecoration(
                                  labelText: 'Number',
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                  hintStyle:
                                      const TextStyle(color: Colors.black),
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  focusedBorder: border,
                                  enabledBorder: border,
                                ),
                                expiryDateDecoration: InputDecoration(
                                  hintStyle:
                                      const TextStyle(color: Colors.black),
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  focusedBorder: border,
                                  enabledBorder: border,
                                  labelText: 'Expired Date',
                                  hintText: 'XX/XX',
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  hintStyle:
                                      const TextStyle(color: Colors.black),
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  focusedBorder: border,
                                  enabledBorder: border,
                                  labelText: 'CVV',
                                  hintText: 'XXX',
                                ),
                                cardHolderDecoration: InputDecoration(
                                  hintStyle:
                                      const TextStyle(color: Colors.black),
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  focusedBorder: border,
                                  enabledBorder: border,
                                  labelText: 'Card Holder',
                                ),
                                onCreditCardModelChange:
                                    onCreditCardModelChange,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                key: const Key("save"),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    primary: Theme.of(context).primaryColor),
                                child: Container(
                                  width: deviceSize.width * 0.3,
                                  margin: const EdgeInsets.all(12),
                                  child: const Text(
                                    'Save',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      package: 'flutter_credit_card',
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  formKey.currentState!.save();
                                  if (formKey.currentState!.validate()) {
                                    saveCreditCard();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void onCreditCardModelChange(model.CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
      _formChanged = true;
    });
  }
}
