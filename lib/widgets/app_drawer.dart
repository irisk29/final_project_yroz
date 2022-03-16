import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/barcode_screen.dart';
import 'package:flutter/material.dart';
import '../screens/tabs_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello, ${Provider.of<User>(context, listen: false).name!}'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Home'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Purchases'),
            onTap: () {

            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.qr_code_scanner),
            title: Text('Scan A Barcode'),
            onTap: () {
              Navigator.pushNamed(context, QRViewExample.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              context.read<User>().signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
