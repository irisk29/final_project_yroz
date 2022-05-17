import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:flutter/material.dart';

import '../widgets/secondary_store_item.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category';

  late String title;

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<StoreDTO> stores = [];

  Future<void> _fetchCategoryStores() async {
    stores = await StoreStorageProxy().fetchCategoryStores(widget.title);
  }

  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.title = routeArgs['title'] as String;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: deviceSize.height * 0.1,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title + " Category",
            style: const TextStyle(
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _fetchCategoryStores(),
        builder: (BuildContext context, AsyncSnapshot snap) {
          return snap.connectionState != ConnectionState.done
              ? Center(child: CircularProgressIndicator())
              : stores.isEmpty
                  ? Container(
                      width: deviceSize.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: deviceSize.width * 0.11,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.category_outlined, size: 40),
                              radius: deviceSize.width * 0.1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(deviceSize.height * 0.01),
                            child: Text(widget.title + " Category",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          Text(
                              "We are sorry, we do not have stores from this category",
                              textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : GridView.count(
                      padding: EdgeInsets.only(
                          top: deviceSize.height * 0.025,
                          bottom: deviceSize.height * 0.025,
                          left: deviceSize.width * 0.075,
                          right: deviceSize.width * 0.075),
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      crossAxisCount: 1,
                      childAspectRatio: 1.6,
                      mainAxisSpacing: deviceSize.height * 0.025,
                      crossAxisSpacing: deviceSize.width * 0.025,
                      children: stores
                          .map((storeData) => SecondaryStoreItem(storeData))
                          .toList(),
                    );
        },
      ),
    );
  }
}
