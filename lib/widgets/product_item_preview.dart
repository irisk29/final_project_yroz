import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../DTOs/ProductDTO.dart';

class ProductItemPreview extends StatelessWidget {
  final ProductDTO product;

  ProductItemPreview(this.product);

  @override
  Widget build(BuildContext context) {
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
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: constraints.maxHeight * 0.125,
                              ),
                            ),
                            product.description != null
                                ? Text(product.description!,
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
                            Text('\€${product.price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16))
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
                    child: product.imageFromPhone != null
                        ? Container(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth * 0.45,
                            child: Image.file(
                                File(product.imageFromPhone!.path),
                                fit: BoxFit.cover),
                          )
                        : product.imageFromPhone == null &&
                                product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: constraints.maxHeight,
                                  width: constraints.maxWidth * 0.45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
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
                                              color: Theme.of(context)
                                                  .errorColor))),
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
