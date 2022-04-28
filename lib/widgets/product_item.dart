import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DTOs/ProductDTO.dart';
import '../LogicLayer/User.dart';

class ProductItem extends StatefulWidget {
  final ProductDTO product;
  final String storeID;

  ProductItem(this.product, this.storeID);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final myController = TextEditingController();

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Card(
          semanticContainer: true,
          elevation: 2,
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.03,
            vertical: constraints.maxHeight * 0.025,
          ),
          shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 0.5,
                color: Colors.black54,
              ),
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: constraints.maxWidth * 0.04,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: constraints.maxWidth * 0.45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: constraints.maxHeight * 0.125,
                              ),
                            ),
                            widget.product.description != null
                                ? Text(widget.product.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: constraints.maxHeight * 0.115,
                                    ))
                                : Container(),
                          ],
                        ),
                      ),
                      Container(
                        width: constraints.maxWidth * 0.45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('\€${widget.product.price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16)),
                            IconButton(
                              icon: Icon(Icons.add_shopping_cart),
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(0),
                              onPressed: () async {
                                user.updateOrCreateCartProduct(
                                    widget.product, widget.storeID, 1);
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added item to cart!',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: constraints.maxWidth * 0.05,
                      top: constraints.maxHeight * 0.06,
                      bottom: constraints.maxHeight * 0.06),
                  child: FittedBox(
                    child: widget.product.imageUrl != null &&
                            widget.product.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.product.imageUrl!,
                            imageBuilder: (context, imageProvider) => Container(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth * 0.45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth * 0.45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/placeholder-image.jpeg'),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth * 0.45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Center(
                                      child: Icon(Icons.error_outline,
                                          color:
                                              Theme.of(context).errorColor))),
                            ),
                          )
                        : Container(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth * 0.45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/default_product.png'),
                                  fit: BoxFit.cover),
                            ),
                          ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
