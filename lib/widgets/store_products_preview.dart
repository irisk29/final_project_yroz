import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/widgets/product_item_preview.dart';
import 'package:flutter/material.dart';

class StoreProductsPreview extends StatelessWidget {
  final List<ProductDTO> products;
  final VoidCallback callback;
  final bool backOnTop;

  StoreProductsPreview(this.products, this.callback, this.backOnTop);

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListTile(
            leading: backOnTop
                ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => callback(),
                  )
                : null,
            title: Text(
              "Products:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            onTap: null,
          ),
          products.length > 0
              ? Expanded(
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    crossAxisCount: 1,
                    childAspectRatio: 3.75,
                    mainAxisSpacing: deviceSize.height * 0.01,
                    crossAxisSpacing: deviceSize.width * 0.025,
                    children: products
                        .map(
                          (storeData) => ProductItemPreview(storeData),
                        )
                        .toList(),
                  ),
                )
              : Center(
                  child: Text("This store does not offer any products for sale",
                      textAlign: TextAlign.center),
                ),
          !backOnTop
              ? ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => callback(),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
