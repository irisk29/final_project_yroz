import 'package:final_project_yroz/DTOs/PhysicalStoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/store_item.dart';

import '../dummy_data.dart';
import '../widgets/category_item.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<PhysicalStoreDTO> DUMMY_STORES = [];

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts(); // WON'T WORK!
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();
    () async {
      DUMMY_STORES = await StoreStorageProxy().fetchAllPhysicalStores();
      setState(() {
        // Update your UI with the desired changes.
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
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
            height: 175,
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
                "Near You",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: GridView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(25),
              children: DUMMY_STORES.isEmpty
                  ? []
                  : [
                      DUMMY_STORES
                          .map(
                            (storeData) => StoreItem(
                              storeData.imageFile,
                              storeData.name,
                              storeData.address,
                            ),
                          )
                          .toList(),
                    ].expand((i) => i).toList(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
