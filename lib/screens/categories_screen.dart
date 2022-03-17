import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../widgets/store_item.dart';

import '../dummy_data.dart';
import '../widgets/category_item.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<StoreDTO> physicalStores = [];
  List<OnlineStoreDTO> onlineStores = [];
  late final _storesFuture;

  @override
  void initState() {
    super.initState();
    _storesFuture = _fetchStores();
  }

  Future<void> _fetchStores() async {
    onlineStores = await StoreStorageProxy().fetchAllOnlineStores();
    physicalStores = await StoreStorageProxy().fetchAllPhysicalStores();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: _storesFuture,
        builder: (BuildContext context, AsyncSnapshot snap) {
          return snap.connectionState != ConnectionState.done
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Container(
                    height: height,
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
                              height: height * 0.23,
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
                                          //widget.user
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
                                  "Physical Stores",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            physicalStores.isEmpty
                                ? SizedBox(height: height * 0.23)
                                : SizedBox(
                                    height: height * 0.23,
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
                                ? SizedBox(height: height * 0.23)
                                : SizedBox(
                                    height: height * 0.23,
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
        });
  }
}
