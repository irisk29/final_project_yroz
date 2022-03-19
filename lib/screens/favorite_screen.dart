import 'package:collection/src/iterable_extensions.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../widgets/store_item.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<StoreDTO> favoriteStores = [];
  List<ProductDTO> favoriteProducts = [];

  @override
  Future<void> didChangeDependencies() async {
    await _fetchFavorites();
    super.didChangeDependencies();
  }

  Future<void> _fetchFavorites() async {
    for (Tuple2<String, bool> store
        in Provider.of<User>(context, listen: true).favoriteStores) {
      if (store.item2) //online store
      {
        ResultInterface res =
            await StoreStorageProxy().getOnlineStore(store.item1);
        if (res.getTag()) {
          if(favoriteStores.firstWhereOrNull((e) => e.id == res.getValue().id) == null)
            favoriteStores.add(res.getValue() as OnlineStoreDTO);
        }
      } else //physical store
      {
        ResultInterface res =
            await StoreStorageProxy().getPhysicalStore(store.item1);
        if (res.getTag()) {
          if(favoriteStores.firstWhereOrNull((e) => e.id == res.getValue().id) == null)
            favoriteStores.add(res.getValue() as StoreDTO);
        }
      }
    }

    for (String product
        in Provider.of<User>(context, listen: true).favoriteProducts) {
      ResultInterface res =
          await StoreStorageProxy().getOnlineStoreProduct(product);
      if (res.getTag()) {
        if(favoriteProducts.firstWhereOrNull((e) => e.id == res.getValue().id) == null)
          favoriteProducts.add(res.getValue() as ProductDTO);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return FutureBuilder(
        future: _fetchFavorites(),
        builder: (BuildContext context, AsyncSnapshot snap) {
          return snap.connectionState != ConnectionState.done
              ? Center(child: CircularProgressIndicator())
              : Container(
                  height: deviceSize.height,
                  child: Column(
                    children: [
                      Container(
                        height: deviceSize.height * 0.01,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0, top: 5),
                          child: Text(
                            "Favorite Stores",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      favoriteStores.isEmpty
                          ? SizedBox(
                              height: deviceSize.height * 0.32,
                              child: Row(
                                children: [
                                  Container(
                                    width: deviceSize.width * 0.4,
                                    height: deviceSize.height * 0.25,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage(
                                            'assets/images/favorite-stores.png'),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "You have no favorite stores yet..."),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pushReplacementNamed(
                                                context, TabsScreen.routeName),
                                        child: Text(
                                          "Click here to find some",
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          : SizedBox(
                              height: deviceSize.height * 0.32,
                              child: GridView(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(
                                    bottom: deviceSize.height * 0.05,
                                    top: deviceSize.height * 0.05,
                                    left: deviceSize.width * 0.035),
                                children: [
                                  favoriteStores
                                      .map(
                                        (storeData) => StoreItem(storeData),
                                      )
                                      .toList(),
                                ].expand((i) => i).toList(),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: deviceSize.height * 0.3,
                                  crossAxisSpacing: deviceSize.height * 0.025,
                                  mainAxisSpacing: deviceSize.width * 0.025,
                                ),
                              ),
                            ),
                      Divider(),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0, top: 5),
                          child: Text(
                            "Favorite Products",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      favoriteProducts.isEmpty
                          ? SizedBox(
                              height: deviceSize.height * 0.32,
                              child: Row(
                                children: [
                                  Container(
                                    width: deviceSize.width * 0.4,
                                    height: deviceSize.height * 0.22,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage(
                                            'assets/images/favorite-products.png'),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "You have no favorite products yet..."),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pushReplacementNamed(
                                                context, TabsScreen.routeName),
                                        child: Text(
                                          "Click here to find some",
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          : SizedBox(
                              height: deviceSize.height * 0.32,
                              child: GridView(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(
                                    bottom: deviceSize.height * 0.05,
                                    top: deviceSize.height * 0.05,
                                    left: deviceSize.width * 0.035),
                                children: [
                                  favoriteProducts
                                      .map(
                                        (storeData) => ProductItem(
                                            storeData, storeData.storeID),
                                      )
                                      .toList(),
                                ].expand((i) => i).toList(),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: deviceSize.height * 0.3,
                                  crossAxisSpacing: deviceSize.height * 0.025,
                                  mainAxisSpacing: deviceSize.width * 0.025,
                                ),
                              ),
                            ),
                    ],
                  ),
                );
        });
  }
}
