import 'dart:typed_data';

import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/PhysicalStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../widgets/store_item.dart';

import '../dummy_data.dart';
import '../widgets/category_item.dart';

class CategoriesScreen extends StatefulWidget {
  User? user;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<PhysicalStoreDTO> physicalStores = [];
  List<OnlineStoreDTO> onlineStores = [];

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts(); // WON'T WORK!
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();
    () async {
      onlineStores = await StoreStorageProxy().fetchAllOnlineStores();
      physicalStores = await StoreStorageProxy().fetchAllPhysicalStores();
      setState(() {
        // Update your UI with the desired changes.
      });
    }();
  }

  @override
  void didChangeDependencies() {
    final user = ModalRoute.of(context)!.settings.arguments as User?;
    if (user != null) widget.user = user;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            Container(
              height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top) *
                  0.09,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 10.0),
                child: Text(
                  "Categories",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top) *
                  0.25,
              child: GridView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(25),
                children: [
                  DUMMY_CATEGORIES
                      .map(
                        (catData) => CategoryItem(
                          catData.id,
                          catData.title,
                          catData.color,
                        ),
                      )
                      .toList(),
                ].expand((i) => i).toList(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            physicalStores.isEmpty
                ? CircularProgressIndicator()
                : SizedBox(
                    height: (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top) *
                        0.25,
                    child: GridView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(25),
                      children: [
                        physicalStores
                            .map(
                              (storeData) => StoreItem(
                                MemoryImage(Uint8List.fromList([0, 0]),
                                    scale: 0.5),
                                storeData.name,
                                storeData.address,
                                storeData.phoneNumber,
                                Map<String, List<TimeOfDay>>.from(
                                    storeData.operationHours),
                                null,
                              ),
                            )
                            .toList(),
                      ].expand((i) => i).toList(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onlineStores.isEmpty
                ? CircularProgressIndicator()
                : SizedBox(
                    height: (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top) *
                        0.25,
                    child: GridView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(25),
                      children: [
                        onlineStores
                            .map(
                              (storeData) => StoreItem(
                                  MemoryImage(Uint8List.fromList([0, 0]),
                                      scale: 0.5),
                                  storeData.name,
                                  storeData.address,
                                  storeData.phoneNumber,
                                  Map<String, List<TimeOfDay>>.from(
                                      storeData.operationHours),
                                  List<ProductDTO>.from(storeData.products)),
                            )
                            .toList(),
                      ].expand((i) => i).toList(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                    ),
                  ),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top) *
                0.01,
            child: SearchBar()),
      ],
    );
  }
}
