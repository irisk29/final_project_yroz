import 'dart:typed_data';

import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
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
  List<StoreDTO> favoriteStores = [];
  List<ProductDTO> favoriteProducts = [];

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts(); // WON'T WORK!
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();

  }

  @override
  void didChangeDependencies() {
    final user = ModalRoute.of(context)!.settings.arguments as User?;
    if (user != null) widget.user = user;
    favoriteStores = user!.favoriteStores;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        height: height,
        child: Column(
              children: [
                Container(
                  height: height * 0.1,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      "Favorite Stores",
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                favoriteStores.isEmpty
                    ? SizedBox(height: height * 0.23)
                    : SizedBox(
                  height: height * 0.23,
                  child: GridView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(height * 0.025),
                    children: [
                      favoriteStores
                          .map(
                            (storeData) => StoreItem(
                              storeData, widget.user!
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
                      "Favorite Products",
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                favoriteStores.isEmpty
                    ? SizedBox(height: height * 0.23)
                    : SizedBox(
                  height: height * 0.23,
                  child: GridView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(height * 0.025),
                    children: [
                      favoriteStores
                          .map(
                            (storeData) => StoreItem(
                              storeData, widget.user!
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

      ),
    );
  }
}