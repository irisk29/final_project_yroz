import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/barcode_screen.dart';
import 'package:final_project_yroz/screens/credit_cards_screen.dart';
import 'package:final_project_yroz/screens/user_purchase_history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'open_online_store_screen.dart';
import 'open_physical_store_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen();

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
    final user = Provider.of<User>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
          top: deviceSize.height * 0.02,
          left: deviceSize.width * 0.03,
          right: deviceSize.width * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: deviceSize.height * 0.13,
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                  padding: EdgeInsets.only(
                      top: deviceSize.height * 0.015,
                      bottom: deviceSize.height * 0.015,
                      left: deviceSize.width * 0.02,
                      right: deviceSize.width * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      CircleAvatar(
                        radius: deviceSize.width * 0.065,
                        backgroundImage: Image.network(user.imageUrl!).image,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      Text(user.name!,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          )),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.only(
                                top: deviceSize.height * 0.01,
                                right: deviceSize.width * 0.03),
                            alignment: Alignment.centerRight,
                            child: !_physicalStoreOwner && !_onlineStoreOwner
                                ? Column(
                                    children: [
                                      Consumer<User>(
                                        builder: (context, user, child) =>
                                            Container(
                                          width: deviceSize.width * 0.3,
                                          height: deviceSize.height * 0.05,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right:
                                                    deviceSize.width * 0.035),
                                            child: SwitchListTile(
                                                activeColor: Colors.purple,
                                                value:
                                                    !user.hideStoreOwnerOptions,
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
                                                onChanged: (_) => user
                                                    .toggleStoreOwnerViewOption()),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Advanced Options",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(deviceSize.width * 0.03),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.purple,
                      ),
                      title: Text(
                        "Total Wallet Balance",
                        style: TextStyle(fontSize: 17),
                      ),
                      trailing: Text(
                        "€" + user.eWalletBalance,
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                    _buildDivider(deviceSize),
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
                    _buildDivider(deviceSize),
                    ListTile(
                      leading: Icon(
                        Icons.history,
                        color: Colors.purple,
                      ),
                      title: Text("My Purchases"),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      onTap: () => Navigator.of(context)
                          .pushNamed(UserPurchasesScreen.routeName),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Consumer<User>(
            builder: (context, user, child) => _physicalStoreOwner ||
                    _onlineStoreOwner ||
                    user.hideStoreOwnerOptions
                ? Container()
                : Padding(
                    padding: EdgeInsets.all(deviceSize.width * 0.03),
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
                          _buildDivider(deviceSize),
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
          ),
          Padding(
            padding: EdgeInsets.all(deviceSize.width * 0.03),
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
            padding: EdgeInsets.all(deviceSize.width * 0.03),
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

  Container _buildDivider(Size deviceSize) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: deviceSize.width * 0.03,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }
}
