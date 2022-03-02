import 'package:final_project_yroz/DTOs/PhysicalStoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/widgets/store_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

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
  var _isInit = true;
  var _isLoading = false;
  late List<PhysicalStoreDTO> DUMMY_STORES;

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
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    widget.title = routeArgs['title'];
    if (_isInit) {
      setState(() {
        _isLoading = false;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
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
          ? Center(
              child: CircularProgressIndicator(),
            )
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
