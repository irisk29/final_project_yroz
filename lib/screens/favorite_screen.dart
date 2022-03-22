import 'package:collection/src/iterable_extensions.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../widgets/secondary_store_item.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late List<StoreDTO> favoriteStores;

  Future<void> _fetchFavorites(User user) async {
    favoriteStores = [];
    for (Tuple2<String, bool> store in user.favoriteStores) {
      if (store.item2) //online store
      {
        ResultInterface res =
            await StoreStorageProxy().getOnlineStore(store.item1);
        if (res.getTag()) {
          if (favoriteStores
                  .firstWhereOrNull((e) => e.id == res.getValue().id) ==
              null) favoriteStores.add(res.getValue() as OnlineStoreDTO);
        }
      } else //physical store
      {
        ResultInterface res =
            await StoreStorageProxy().getPhysicalStore(store.item1);
        if (res.getTag()) {
          if (favoriteStores
                  .firstWhereOrNull((e) => e.id == res.getValue().id) ==
              null) favoriteStores.add(res.getValue() as StoreDTO);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return Consumer<User>(
      builder: (context, user, _) => FutureBuilder(
        future: _fetchFavorites(user),
        builder: (BuildContext context, AsyncSnapshot snap) {
          return snap.connectionState != ConnectionState.done
              ? Center(child: CircularProgressIndicator())
              : favoriteStores.isEmpty
                  ? Container(
                      width: deviceSize.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 45.0,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.favorite_border, size: 35),
                              radius: 40.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Favorites",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          Text(
                              "Save here stores that you want to visit again.\n For now, you have no favorite stores...",
                              textAlign: TextAlign.center),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                                context, TabsScreen.routeName),
                            child: Text(
                              "Click here to find some",
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                            ),
                          )
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
                      children: favoriteStores
                          .map((storeData) => SecondaryStoreItem(storeData))
                          .toList(),
                    );
        },
      ),
    );
  }
}
