import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

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
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
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

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  late AnimationController _controller;
  late Animation<Size> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _heightAnimation = Tween<Size>(
            end: Size(double.infinity, 320.0),
            begin: Size(double.infinity, 260.0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _heightAnimation.addListener(() => setState(() {}));
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

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image.asset('assets/icon/yroz5.png'),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Column(
                    children: [
                      SignInButton(
                        Buttons.Google,
                        onPressed: () {
                         Provider.of<User>(context, listen: false)
                              .signIn(AuthProvider.google, context);
                          //TODO: ADD CALL TO ERROR DIALOG IF FAILS
                        },
                      ),
                      SignInButton(
                        Buttons.FacebookNew,
                        onPressed: () {
                          Provider.of<User>(context, listen: false)
                              .signIn(AuthProvider.facebook, context);
                          //TODO: ADD CALL TO ERROR DIALOG IF FAILS
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
