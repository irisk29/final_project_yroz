import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/add_bank_account_screen.dart';
import 'package:final_project_yroz/screens/credit_cards_screen.dart';
import 'package:final_project_yroz/screens/manage_online_store_screen.dart';
import 'package:final_project_yroz/screens/manage_physical_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_online_store_screen.dart';
import 'edit_physical_store_screen.dart';
import 'open_online_store_screen.dart';
import 'open_physical_store_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsScreen> {
  late bool _physicalStoreOwner;
  late bool _onlineStoreOwner;
  var _isInit = true;
  //User? _user = User("", "");

  @override
  void initState() {
    super.initState();
    _physicalStoreOwner = false;
    _onlineStoreOwner = false;
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      //final user = ModalRoute.of(context)!.settings.arguments as User?;
      if (Provider.of<User>(context, listen: false).storeOwnerState != null) {
        _physicalStoreOwner = Provider.of<User>(context, listen: false).storeOwnerState!.physicalStore != null;
        _onlineStoreOwner = Provider.of<User>(context, listen: false).storeOwnerState!.onlineStore != null;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
        ),
        actions: <Widget>[],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  elevation: 8.0,
                  child: Container(
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        onTap: () {
                          //open edit profile
                        },
                        title: Text(
                          Provider.of<User>(context, listen: false).name!,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        leading: CircleAvatar(
                          radius: 30.0,
                          backgroundImage:
                              Image.network(Provider.of<User>(context, listen: false).imageUrl!).image,
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.language,
                          color: Colors.purple,
                        ),
                        title: Text("Change Language"),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          //open change language
                        },
                      ),
                      _buildDivider(),
                      ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.purple,
                        ),
                        title: Text("Change Location"),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          //open change location
                        },
                      ),
                      _buildDivider(),
                      ListTile(
                        leading: Icon(
                          Icons.credit_card,
                          color: Colors.purple,
                        ),
                        title: Text("Credit Cards"),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          Navigator.of(context).pushNamed(CreditCardsScreen.routeName);
                          //open change language
                        },
                      ),
                      _buildDivider(),
                      ListTile(
                        leading: Icon(
                          Icons.account_balance,
                          color: Colors.purple,
                        ),
                        title: Text("Add Bank Account"),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          Navigator.of(context).pushNamed(AddBankAccountScreen.routeName);
                          //open change language
                        },
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(children: <Widget>[
                    !_physicalStoreOwner
                        ? ListTile(
                            leading: Icon(
                              Icons.store,
                              color: Colors.purple,
                            ),
                            title: !_onlineStoreOwner
                                ? Text("Open Online Store")
                                : Text("Manage Online Store"),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              !_onlineStoreOwner
                                  ? Navigator.of(context).pushNamed(
                                  OpenOnlineStorePipeline.routeName,
                                  )
                                  : Navigator.of(context).pushNamed(
                                  ManageOnlineStoreScreen.routeName,
                                  )
                              ;
                            },
                          )
                        : Container(),
                  ]),
                ),
                const SizedBox(height: 20.0),
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(children: <Widget>[
                    !_onlineStoreOwner
                        ? ListTile(
                            leading: Icon(
                              Icons.store,
                              color: Colors.purple,
                            ),
                            title: !_physicalStoreOwner
                                ? Text("Open Physical Store")
                                : Text("Manage Physical Store"),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              !_physicalStoreOwner
                                  ? Navigator.of(context).pushNamed(
                                  OpenPhysicalStorePipeline.routeName,
                                  )
                                  : Navigator.of(context).pushNamed(
                                  ManagePhysicalStoreScreen.routeName,
                                  )
                              ;
                            },
                          )
                        : Container(),
                  ]),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Notification Settings",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SwitchListTile(
                  activeColor: Colors.purple,
                  contentPadding: const EdgeInsets.all(0),
                  value: true,
                  title: Text("Received notification"),
                  onChanged: (val) {},
                ),
                const SizedBox(height: 60.0),
              ],
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
