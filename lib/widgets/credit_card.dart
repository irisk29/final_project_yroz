import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreditCardWidget extends StatefulWidget {
  final String name;
  final String fourDigits;
  final String expiration;
  final Color color;
  final String token;

  CreditCardWidget(
      this.name, this.fourDigits, this.expiration, this.color, this.token);

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  static const _animDuration = 3;

  late AnimationController _controller;
  late Map<Type, GestureRecognizerFactory> _customGestures;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(seconds: _animDuration),
    );

    _widthAnimation = Tween<double>(begin: 0.0, end: 200).animate(_controller);
    _customGestures = Map<Type, GestureRecognizerFactory>();
    _customGestures[LongPressGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
      () => LongPressGestureRecognizer(
          duration: Duration(seconds: _animDuration), debugOwner: this),
      (LongPressGestureRecognizer instance) {
        instance
          ..onLongPress = () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Are you sure?'),
                content: Text(
                  'You are about to remove your credit card, do you want to do so?',
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                  FlatButton(
                    key: const Key("yes"),
                    child: Text('Yes'),
                    onPressed: () async {
                      await Provider.of<User>(context, listen: false)
                          .removeCreditCardToken(widget.token);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            );
          }
          ..onLongPressStart = (details) {
            _controller.forward();
          }
          ..onLongPressMoveUpdate = (details) {}
          ..onLongPressEnd = (details) {
            _controller.reverse();
          }
          ..onLongPressUp = () {};
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: RawGestureDetector(
          gestures: _customGestures,
          key: Key(widget.fourDigits),
          child: Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.75,
                child: Card(
                  color: widget.color,
                  elevation: 3,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          top: constraints.maxHeight * 0.225,
                          left: constraints.maxWidth * 0.075,
                          child: Image.asset("assets/images/chip1.png")),
                      Positioned(
                          top: constraints.maxHeight * 0.2,
                          left: constraints.maxWidth * 0.5,
                          child: Text(
                            '••••  ${widget.fourDigits}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: Color.fromRGBO(10, 113, 119, 1),
                                fontSize: 18,
                                height: 2),
                          )),
                      Positioned(
                          top: constraints.maxHeight * 0.5,
                          left: constraints.maxWidth * 0.1,
                          child: Text(
                            '${widget.name}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Color.fromRGBO(20, 19, 42, 1),
                                height: 1.5),
                          )),
                      Positioned(
                          top: constraints.maxHeight * 0.075,
                          left: constraints.maxWidth * 0.725,
                          child: Text(
                            '${widget.expiration}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: Color.fromRGBO(10, 113, 119, 1),
                                fontSize: 14,
                                height: 1.5),
                          )),
                      Positioned(
                          top: constraints.maxHeight * 0.21,
                          left: constraints.maxWidth * 0.26,
                          child: Image.asset("assets/images/nfc1.png")),
                      Positioned(
                          top: constraints.maxHeight * 0.425,
                          left: constraints.maxWidth * 0.65,
                          child: Image.asset("assets/images/visa1.png")),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.5,
                    color: Colors.grey,
                    style: BorderStyle.solid,
                  ),
                  color: Colors.white,
                ),
                width: 200,
                height: 50,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: _widthAnimation.value,
                        color: Colors.indigo,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
