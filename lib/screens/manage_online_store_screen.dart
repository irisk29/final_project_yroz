import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/edit_online_store_screen.dart';
import 'package:final_project_yroz/screens/store_purchase_history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_bank_account.dart';

class ManageOnlineStoreScreen extends StatefulWidget {
  static const routeName = '/manage-online-store';

  late OnlineStoreDTO store;

  @override
  _ManageOnlineStoreScreenState createState() =>
      _ManageOnlineStoreScreenState();
}

class _ManageOnlineStoreScreenState extends State<ManageOnlineStoreScreen> {
  @override
  void didChangeDependencies() {
    widget.store =
        Provider.of<User>(context, listen: false).storeOwnerState!.onlineStore!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: true);
    final notificationCount = user.storeOwnerState!.newPurchasesNoViewed;
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: deviceSize.height * 0.1,
        title: Text(
          widget.store.name,
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: widget.store.image != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(widget.store.image!))
                      : DecorationImage(
                          image: AssetImage('assets/images/default-store.png'),
                          fit: BoxFit.cover),
                ),
              ),
            ),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: Colors.purple,
                    ),
                    title: Text("Edit Store Details"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => Navigator.of(context)
                        .pushNamed(EditOnlineStorePipeline.routeName),
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      Icons.account_balance,
                      color: Colors.purple,
                    ),
                    title: Text("Edit Bank Account Details"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => Navigator.of(context)
                        .pushNamed(EditBankAccountScreen.routeName),
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Stack(
                      children: <Widget>[
                        Icon(
                          Icons.history,
                          color: Colors.purple,
                        ),
                        notificationCount > 0
                            ? Positioned(
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: Text(
                                    '$notificationCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text("View Store Purchases"),
                    onTap: () => Navigator.of(context)
                        .pushNamed(StorePurchasesScreen.routeName),
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      Icons.qr_code_2_sharp,
                      color: Colors.purple,
                    ),
                    title: Text("Store QR Code"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text('QR Code', style: TextStyle(fontSize: 25),),
                              content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  Image.network(
                                      widget.store.qrCode!,
                                      fit: BoxFit.cover,
                                  )
                              ],
                          ),)),
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      Icons.arrow_circle_down,
                      color: Colors.purple,
                    ),
                    title: Text("Downgrade to Physical Store"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () =>
                        user.convertOnlineStoreToPhysical(widget.store),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                primary: Colors.red,
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                child: const Text(
                  'DELETE STORE',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              onPressed: () => user.deleteStore(widget.store.id, false),
            ),
          ],
        ),
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
