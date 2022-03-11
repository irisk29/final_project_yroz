import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../widgets/store_item.dart';

class FavoriteScreen extends StatefulWidget {
  User? user;

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
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
    () async {
      favoriteStores = [];
      for(Tuple2<String,bool> store in user!.favoriteStores){
        if(store.item2) //online store
        {
          ResultInterface res = await StoreStorageProxy().getOnlineStore(store.item1);
          if(res.getTag()){
            favoriteStores.add(res.getValue() as OnlineStoreDTO);
          }
        }
        else //physical store
        {
          ResultInterface res = await StoreStorageProxy().getPhysicalStore(store.item1);
          if(res.getTag()){
            favoriteStores.add(res.getValue() as StoreDTO);
          }
        }
      }
      setState(() {
        // Update your UI with the desired changes.
      });
    }(); 
    
    () async {
      favoriteProducts = [];
      for(String product in user!.favoriteProducts){
        ResultInterface res = await StoreStorageProxy().getOnlineStoreProduct(product);
        if(res.getTag()){
          favoriteProducts.add(res.getValue() as ProductDTO);
        }
      }
      setState(() {
        // Update your UI with the desired changes.
      });
    }();
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
                  height: height * 0.01,
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
                favoriteProducts.isEmpty
                    ? SizedBox(height: height * 0.23)
                    : SizedBox(
                  height: height * 0.23,
                  child: GridView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(height * 0.025),
                    children: [
                      favoriteProducts
                          .map(
                            (storeData) => ProductItem(
                              storeData, widget.user!, storeData.storeID
                            ),
                      ).toList(),
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
