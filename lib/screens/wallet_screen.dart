import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {

  static const routeName = '/payment';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(243, 90, 106, 1.0).withOpacity(0.5),
                  Color.fromRGBO(243, 90, 106, 1.0).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height / 1.3,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: PaymentCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentCard extends StatefulWidget {
  const PaymentCard({
    Key? key,
  }) : super(key: key);

  @override
  _PaymentCardState createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  AnimationController? _controller;
  Animation<Size>? _heightAnimation;
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _heightAnimation = Tween<Size>(
        end: Size(double.infinity, 320.0),
        begin: Size(double.infinity, 260.0))
        .animate(
        CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn));
    _heightAnimation!.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    double cashback = 0.0;
    final _initValues = {
      'cashback': 75.0,
    };
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: 320,
        constraints: BoxConstraints(minHeight: 320),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.payments_outlined),
                  ),
                  TextSpan(text: "Cashback available: "+_initValues['cashback'].toString(), style: TextStyle(color: Colors.black, fontSize: 16.0)),
                ],
              ),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Cashback to use'),
              keyboardType: TextInputType.number,
              controller: myController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a number.';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  if(value!="")
                    cashback = double.parse(value);
                  else
                    cashback = 0;
                });
              },
            ),
            Text('Amount left to pay: '+ (_initValues['cashback']! - (myController.text.length>0 ? double.parse(myController.text) : 0)).toString()),
            FlatButton(
              child: Text('Confirm Amount'),
              onPressed: () {

              },
            )
          ],
        ),
      ),
    );
  }
}