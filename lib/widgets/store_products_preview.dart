import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/widgets/product_item_preview.dart';
import 'package:flutter/material.dart';

class StoreProductsPreview extends StatelessWidget {
  final List<ProductDTO> products;
  final VoidCallback callback;

  StoreProductsPreview(this.products, this.callback);

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return SizedBox(
      height: deviceSize.height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListTile(
            title: Text(
              "Products:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            onTap: null,
          ),
          products.length > 0
              ? Container(
                  height: deviceSize.height * 0.45,
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    crossAxisCount: 1,
                    childAspectRatio: 3.5,
                    mainAxisSpacing: deviceSize.height * 0.01,
                    crossAxisSpacing: deviceSize.width * 0.025,
                    children: products
                        .map(
                          (storeData) => ProductItemPreview(storeData),
                        )
                        .toList(),
                  ),
                )
              : Container(
                  width: deviceSize.width,
                  height: deviceSize.height * 0.45,
                  child: Center(
                    child: Text(
                        "This store does not offer any products for sale",
                        textAlign: TextAlign.center),
                  ),
                ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  left: deviceSize.width * 0.02,
                  right: deviceSize.width * 0.02,
                  bottom: deviceSize.width * 0.02),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.5,
                      color: Colors.black54,
                    ),
                    borderRadius: BorderRadius.circular(10.0)),
                child: ListTile(
                  title: Text(
                    "Back To Store Page",
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () => callback(),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
