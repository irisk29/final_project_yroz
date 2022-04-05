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
                  Color.fromRGBO(255, 179, 179, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0],
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
                  AuthCard(),
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
  GlobalKey stickyKey = GlobalKey();
  late AnimationController _controller;
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
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

  Future<void> _authenticate(AuthProvider authProvider) async {
    setState(() => _isLoading = true);
    await Provider.of<User>(context, listen: false)
        .signIn(authProvider, context);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 8.0,
            child: AnimatedContainer(
              key: stickyKey,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              width: deviceSize.width * 0.75,
              padding: EdgeInsets.all(deviceSize.width * 0.05),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/icon/yroz.png'),
                    Padding(
                      padding: EdgeInsets.all(deviceSize.width * 0.025),
                      child: Column(
                        children: [
                          SignInButton(
                            Buttons.Google,
                            onPressed: () => _authenticate(AuthProvider.google),
                          ),
                          SignInButton(
                            Buttons.FacebookNew,
                            onPressed: () =>
                                _authenticate(AuthProvider.facebook),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _isLoading
            ? Stack(
                children: [
                  Center(
                    child: Card(
                      color: Colors.white24.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 8.0,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        width: deviceSize.width * 0.75,
                        padding: EdgeInsets.all(deviceSize.width * 0.05),
                        constraints: BoxConstraints(
                            minHeight: (stickyKey.currentContext!
                                    .findRenderObject() as RenderBox)
                                .size
                                .height),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(deviceSize.width * 0.05),
                    constraints: BoxConstraints(
                        minHeight: (stickyKey.currentContext!.findRenderObject()
                                as RenderBox)
                            .size
                            .height),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : SizedBox()
      ],
    );
  }
}
