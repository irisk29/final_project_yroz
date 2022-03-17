import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class OnlinePaymentScreen extends StatefulWidget {
  static const routeName = '/online-payment';

  late String storeID;
  late ShoppingBagDTO bag;

  @override
  State<OnlinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {

  @override
  void didChangeDependencies() {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.storeID = routeArgs['store'] as String;
    widget.bag = routeArgs['bag'] as ShoppingBagDTO;
  }

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
                    child: PaymentCard(storeID: widget.storeID, bag: widget.bag,),
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
  final String? storeID;
  final ShoppingBagDTO? bag;

  const PaymentCard({
    Key? key,
    this.storeID,
    this.bag
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
  final _initValues = {
    'cashback': 0.0,
  };

  String dropdownvalue = '';

  List<Tuple2<String,String>> items = [];

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
    initCashBack();
    activeCreditCards();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> activeCreditCards() async {
    Map<String, Map<String, dynamic>> creditCards =
    await Provider.of<User>(context, listen: false).getUserCreditCardDetails();
    creditCards.forEach((token, creditCard) {
      DateTime expirationDate = new DateFormat('MM/yy').parse(creditCard['expiryDate']);
      if (DateTime.now().isBefore(expirationDate)) //not expired
          {
        items.add(Tuple2<String,String>(creditCard['cardNumber'].toString().substring(12), token));
      }
    });
  }

  void initCashBack() async {
    String cb = await Provider.of<User>(context, listen: false).getEWalletBalance();
    _initValues['cashback'] = double.parse(cb);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    double cashback = 0.0;

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
            Text("Purchase amount: ${widget.bag!.calculateTotalPrice().toString()}", style: TextStyle(color: Colors.black, fontSize: 20.0)),
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
            DropdownButton(
              value: dropdownvalue,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: items.map((Tuple2<String,String> items) {
                return DropdownMenuItem(
                  value: items.item2,
                  child: Text(items.item1),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
            ),
            Text('Amount left to pay: '+ (widget.bag!.calculateTotalPrice() - (myController.text.length>0 ? double.parse(myController.text) : 0)).toString()),
            FlatButton(
              child: Text('Confirm Amount'),
              onPressed: () async {
                await Provider.of<User>(context, listen: false).makePaymentPhysicalStore(dropdownvalue, cashback.toString(), (widget.bag!.calculateTotalPrice() - (myController.text.length>0 ? double.parse(myController.text) : 0.0)).toString(), widget.storeID!);
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}