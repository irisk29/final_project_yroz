import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/barcode_screen.dart';
import 'package:final_project_yroz/screens/credit_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'open_online_store_screen.dart';
import 'open_physical_store_screen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late bool _physicalStoreOwner;
  late bool _onlineStoreOwner;
  var _isInit = true;

  @override
  void initState() {
    super.initState();
    _physicalStoreOwner = false;
    _onlineStoreOwner = false;
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (Provider.of<User>(context, listen: false).storeOwnerState != null) {
        _physicalStoreOwner = Provider.of<User>(context, listen: false)
                .storeOwnerState!
                .physicalStore !=
            null;
        _onlineStoreOwner = Provider.of<User>(context, listen: false)
                .storeOwnerState!
                .onlineStore !=
            null;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                onTap: null,
                title: Text(
                  user.name!,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: Image.network(user.imageUrl!).image,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.credit_card,
                      color: Colors.purple,
                    ),
                    title: Text("My Credit Cards"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(CreditCardsScreen.routeName);
                      //open change language
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      Icons.history,
                      color: Colors.purple,
                    ),
                    title: Text("My Purchases"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          _physicalStoreOwner || _onlineStoreOwner
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(
                            Icons.storefront,
                            color: Colors.purple,
                          ),
                          title: Text("Open Physical Store"),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () => Navigator.of(context).pushNamed(
                            OpenPhysicalStorePipeline.routeName,
                          ),
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: Icon(
                            Icons.store_outlined,
                            color: Colors.purple,
                          ),
                          title: Text("Open Online Store"),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () => Navigator.of(context).pushNamed(
                            OpenOnlineStorePipeline.routeName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: ListTile(
                leading: Icon(
                  Icons.qr_code_scanner,
                  color: Colors.purple,
                ),
                title: Text("Scan A Barcode"),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, QRViewExample.routeName);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: Colors.purple,
                ),
                title: Text("Logout"),
                onTap: () => context.read<User>().signOut(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }
}
