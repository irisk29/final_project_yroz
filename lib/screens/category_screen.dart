import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/widgets/store_item.dart';
import 'package:flutter/material.dart';

enum FilterOptions {
  Favorites,
  All,
}

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category';
  String? title;

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  var _isLoading = true;
  List<StoreDTO> DUMMY_STORES = [];

  @override
  void initState() {
    super.initState();
    () async {
      DUMMY_STORES = await StoreStorageProxy().fetchAllPhysicalStores();
      if(DUMMY_STORES.length==0) {
        _isLoading = false;
      }
      List<StoreDTO> toRemove = [];
      if(DUMMY_STORES.length>0) {
        for (StoreDTO store in DUMMY_STORES) {
          if (!store.categories.contains(widget.title!))
              toRemove.add(store);
        }
        DUMMY_STORES.removeWhere((element) => toRemove.contains(element));
        _isLoading = false;
      }
      setState(() {

      });
    }();
  }

  @override
  void didChangeDependencies() {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    widget.title = routeArgs['title'];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title!,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(),)
          : GridView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(25),
              children: [
                DUMMY_STORES
                    .map(
                      (storeData) => StoreItem(
                        storeData.imageFile,
                        storeData.name,
                        storeData.address,
                        storeData.phoneNumber,
                        Map<String,List<TimeOfDay>>.from(storeData.operationHours),
                        null
                      ),
                    )
                    .toList(),
              ].expand((i) => i).toList(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
            ),
    );
  }
}
