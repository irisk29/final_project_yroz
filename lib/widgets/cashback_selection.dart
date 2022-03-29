import 'package:flutter/material.dart';

class CashbackSelection extends StatefulWidget {
  final form = GlobalKey<FormState>();
  double cashbackAmount = 0.0;
  final double cashbackAvailable;

  CashbackSelection(this.cashbackAvailable);

  @override
  _CashbackSelectionState createState() => _CashbackSelectionState();
}

class _CashbackSelectionState extends State<CashbackSelection> {
  final myController = TextEditingController();
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
      height: _expanded ? 160 : 50,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            title: Text(
              'CASHBACK',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
              ),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () async {
                if (!_expanded || (_expanded && myController.text.isEmpty))
                  setState(() {
                    _expanded = !_expanded;
                  });
              },
            ),
          ),
          _expanded
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeIn,
                  height: 110,
                  child: Form(
                    key: widget.form,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined),
                                Text(" Cashback Available",
                                    style: TextStyle(fontSize: 15.0)),
                              ],
                            ),
                            Text("\€" + widget.cashbackAvailable.toString(),
                                style: TextStyle(fontSize: 15.0)),
                          ],
                        ),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Cashback to use'),
                          keyboardType: TextInputType.number,
                          controller: myController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            if (double.parse(value) < 0) {
                              return 'Please enter a positive amount';
                            }
                            if (double.parse(value) >
                                widget.cashbackAvailable) {
                              return 'You do not have enough cashback';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value != "")
                              widget.cashbackAmount = double.parse(value);
                            else
                              widget.cashbackAmount = 0;
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
