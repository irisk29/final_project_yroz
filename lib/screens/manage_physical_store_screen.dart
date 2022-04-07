import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/edit_bank_account.dart';
import 'package:final_project_yroz/screens/edit_physical_store_screen.dart';
import 'package:final_project_yroz/screens/store_purchase_history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManagePhysicalStoreScreen extends StatefulWidget {
  static const routeName = '/manage-physical-store';

  late StoreDTO store;

  @override
  _ManagePhysicalStoreScreenState createState() =>
      _ManagePhysicalStoreScreenState();
}

class _ManagePhysicalStoreScreenState extends State<ManagePhysicalStoreScreen> {
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    if (!isLoading) {
      widget.store = Provider.of<User>(context, listen: false)
          .storeOwnerState!
          .physicalStore!;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: true);
    var notificationCount = 0;
    if (user.storeOwnerState != null) {
      notificationCount = user.storeOwnerState!.newPurchasesNoViewed;
    }
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: deviceSize.height * 0.1,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.store.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.store.categories.join(", "),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      height: deviceSize.height * 0.3,
                      decoration: BoxDecoration(
                        image: widget.store.image != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(widget.store.image!))
                            : DecorationImage(
                                image: AssetImage(
                                    'assets/images/default-store.png'),
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
                              .pushNamed(EditPhysicalStorePipeline.routeName),
                        ),
                        _buildDivider(deviceSize),
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
                        _buildDivider(deviceSize),
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
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                        _buildDivider(deviceSize),
                        ListTile(
                          leading: Icon(
                            Icons.qr_code_2,
                            color: Colors.purple,
                          ),
                          title: Text("Store QR Code"),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text(
                                      'QR Code',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.network(
                                          widget.store.qrCode!,
                                          fit: BoxFit.cover,
                                        )
                                      ],
                                    ),
                                  )),
                        ),
                        _buildDivider(deviceSize),
                        ListTile(
                            leading: Icon(
                              Icons.arrow_circle_up,
                              color: Colors.purple,
                            ),
                            title: Text("Upgrade to Online Store"),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Upgrade to Online Store'),
                                  content: Text(
                                    'Upgrading your store to online store means that you can upload and sell your products within the app.',
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        setState(() {
                                          isLoading = true;
                                        });
                                        user
                                            .convertPhysicalStoreToOnline(
                                                widget.store)
                                            .then((_) => Navigator.of(context)
                                                .pop(false));
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
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
                      margin: EdgeInsets.all(deviceSize.width * 0.025),
                      child: const Text(
                        'DELETE STORE',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Are you sure?'),
                          content: Text(
                            'Deleting your store means that all information on it will be deleted, you will not be able to restored this action.',
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                            ),
                            FlatButton(
                              child: Text('Yes'),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                setState(() {
                                  isLoading = true;
                                });
                                user.deleteStore(widget.store.id, false).then(
                                    (_) => Navigator.of(context).pop(false));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
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
