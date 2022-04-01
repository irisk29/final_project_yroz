import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../widgets/default_store_item.dart';

import '../dummy_data.dart';
import '../widgets/category_item.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen();

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<StoreDTO> physicalStores = [];
  List<OnlineStoreDTO> onlineStores = [];

  Future<void> _fetchStores() async {
    onlineStores = await StoreStorageProxy().fetchAllOnlineStores();
    physicalStores = await StoreStorageProxy().fetchAllPhysicalStores();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var height = constraints.maxHeight * 1.3;
        return FutureBuilder(
          future: _fetchStores(),
          builder: (BuildContext context, AsyncSnapshot snap) {
            return snap.connectionState != ConnectionState.done
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Container(
                      height: height * 0.95,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: height * 0.1,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    "Categories",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.22,
                                child: GridView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(height * 0.025),
                                  children: [
                                    DUMMY_CATEGORIES
                                        .map(
                                          (catData) => CategoryItem(
                                              catData.id,
                                              catData.title,
                                              catData.color,
                                              catData.image),
                                        )
                                        .toList(),
                                  ].expand((i) => i).toList(),
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 200,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                  ),
                                ),
                              ),
                              Divider(),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    "Physical Stores",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              physicalStores.isEmpty
                                  ? SizedBox(
                                      height: height * 0.22,
                                      child: Center(
                                        child: Text(
                                            "Currently there are no physical stores to display"),
                                      ),
                                    )
                                  : SizedBox(
                                      height: height * 0.22,
                                      child: GridView(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.all(height * 0.025),
                                        children: [
                                          physicalStores
                                              .map(
                                                (storeData) => StoreItem(
                                                    storeData //, widget.user!
                                                    ),
                                              )
                                              .toList(),
                                        ].expand((i) => i).toList(),
                                        gridDelegate:
                                            SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 200,
                                          childAspectRatio: 1,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20,
                                        ),
                                      ),
                                    ),
                              Divider(),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    "Online Stores",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              onlineStores.isEmpty
                                  ? SizedBox(
                                      height: height * 0.22,
                                      child: Center(
                                        child: Text(
                                            "Currently there are no online stores to display"),
                                      ),
                                    )
                                  : SizedBox(
                                      height: height * 0.22,
                                      child: GridView(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.all(height * 0.025),
                                        children: [
                                          onlineStores
                                              .map(
                                                (storeData) => StoreItem(
                                                    storeData //, widget.user!
                                                    ),
                                              )
                                              .toList(),
                                        ].expand((i) => i).toList(),
                                        gridDelegate:
                                            SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 200,
                                          childAspectRatio: 1,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          SearchBar(),
                        ],
                      ),
                    ),
                  );
          },
        );
      },
    );
  }
}
