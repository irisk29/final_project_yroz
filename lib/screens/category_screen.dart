import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/widgets/store_item.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category';
  String? title;
  //User? user;

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  var _isLoading = true;
  List<StoreDTO> stores = []; // TODO: ADD ONLINE STORES

  @override
  void initState() {
    super.initState();
    () async {
      stores = await StoreStorageProxy().fetchAllPhysicalStores();
      if(stores.length==0) {
        _isLoading = false;
      }
      List<StoreDTO> toRemove = [];
      if(stores.length>0) {
        for (StoreDTO store in stores) {
          if (!store.categories.contains(widget.title!))
              toRemove.add(store);
        }
        stores.removeWhere((element) => toRemove.contains(element));
        _isLoading = false;
      }
      setState(() {

      });
    }();
  }

  @override
  void didChangeDependencies() {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.title = routeArgs['title'] as String;
    //widget.user = routeArgs['user'] as User;
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
            stores
              .map(
                (storeData) => StoreItem(
                  storeData//, widget.user!
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
