import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:provider/provider.dart';

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';

class AddCreditCardScreen extends StatefulWidget {
  static const routeName = '/add-credit-card';

  @override
  State<StatefulWidget> createState() {
    return AddCreditCardScreenState();
  }
}

class AddCreditCardScreenState extends State<AddCreditCardScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late Secret secret;

  var _isLoading = false;

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  Future<void> saveCreditCard() async {
    setState(() {
      _isLoading = true;
    });
    secret = await SecretLoader(secretPath: "assets/secrets.json").load();

    final key = encrypt.Key.fromUtf8(secret.KEY);
    final iv = encrypt.IV.fromUtf8(secret.IV);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(cardNumber, iv: iv);
    print(encrypted.base16);
    cardNumber = encrypted.base16;
    final res = await Provider.of<User>(context, listen: false).addCreditCard(
        cardNumber.toString(), expiryDate, cvvCode, cardHolderName);

    setState(() {
      _isLoading = false;
    });

    if (res.getTag()) {
      Navigator.of(context).pop(true);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text(res.getMessage()),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(ctx).pop(false);
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: deviceSize.height * 0.1,
          title: Text(
            "New Credit Card",
            style: const TextStyle(fontSize: 22),
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
                        cardBgColor: Colors.indigo,
                        backgroundImage:
                            useBackgroundImage ? 'assets/card_bg.png' : null,
                        isSwipeGestureEnabled: true,
                        onCreditCardWidgetChange:
                            (CreditCardBrand creditCardBrand) {},
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              CreditCardForm(
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
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    primary:
                                        Color.fromARGB(255, 104, 120, 206)),
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 16,
                                      package: 'flutter_credit_card',
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    print('valid!');
                                    saveCreditCard();
                                  } else {
                                    print('invalid!');
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

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
