import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManagePhysicalStoreScreen extends StatefulWidget {
  static const routeName = '/manage-physical-store';

  late StoreDTO? store;

  @override
  _ManagePhysicalStoreScreenState createState() => _ManagePhysicalStoreScreenState();

}

class _ManagePhysicalStoreScreenState extends State<ManagePhysicalStoreScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    widget.store = Provider.of<User>(context, listen: false).storeOwnerState!.physicalStore;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.store!.name,
        ),
        actions: [

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: widget.store!.imageFromPhone != null
                      ? DecorationImage(fit: BoxFit.cover, image: FileImage(widget.store!.imageFromPhone!))
                      : DecorationImage(
                      image: AssetImage('assets/images/default-store.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  "Actions:",
                  style:
                  TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      Icons.account_balance,
                      color: Colors.purple,
                    ),
                    title: Text("Add Bank Account"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      //open change language
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      Icons.arrow_circle_up,
                      color: Colors.purple,
                    ),
                    title: Text("Make Online Store"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      //open change location
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: Colors.purple,
                    ),
                    title: Text("Edit Store"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      //open change language
                    },
                  ),
                ],
              ),
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
