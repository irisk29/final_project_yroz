import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/widgets/store_preview.dart';
import 'package:flutter/material.dart';

class StorePreviewScreen extends StatefulWidget {
  static const routeName = '/store-preview';

  late StoreDTO store;

  @override
  _StorePreviewScreenState createState() => _StorePreviewScreenState();
}

class _StorePreviewScreenState extends State<StorePreviewScreen> {
  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.store = routeArgs['store'] as StoreDTO;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: deviceSize.height * 0.1,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                widget.store.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.store.categories.join(", "),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SizedBox(
          height: deviceSize.height,
          child: Column(children: [
            StorePreview(
                widget.store is OnlineStoreDTO,
                widget.store.name,
                widget.store.address,
                null,
                widget.store.image,
                widget.store.phoneNumber,
                widget.store.operationHours,
                widget.store is OnlineStoreDTO
                    ? (widget.store as OnlineStoreDTO).products
                    : null,
                false),
          ]),
        ),
      ),
    );
  }
}
