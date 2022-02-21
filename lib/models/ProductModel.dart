/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, file_names, unnecessary_new, prefer_if_null_operators, prefer_const_constructors, slash_for_doc_comments, annotate_overrides, non_constant_identifier_names, unnecessary_string_interpolations, prefer_adjacent_string_concatenation, unnecessary_const, dead_code

import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the ProductModel type in your schema. */
@immutable
class ProductModel extends Model {
  static const classType = const _ProductModelModelType();
  final String id;
  final String name;
  final String categories;
  final double price;
  final String imageUrl;
  final String description;
  final String onlinestoremodelID;
  final String shoppingbagmodelID;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  const ProductModel._internal(
      {@required this.id,
      this.name,
      this.categories,
      this.price,
      this.imageUrl,
      this.description,
      this.onlinestoremodelID,
      this.shoppingbagmodelID});

  factory ProductModel(
      {String id,
      String name,
      String categories,
      double price,
      String imageUrl,
      String description,
      String onlinestoremodelID,
      String shoppingbagmodelID}) {
    return ProductModel._internal(
        id: id == null ? UUID.getUUID() : id,
        name: name,
        categories: categories,
        price: price,
        imageUrl: imageUrl,
        description: description,
        onlinestoremodelID: onlinestoremodelID,
        shoppingbagmodelID: shoppingbagmodelID);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductModel &&
        id == other.id &&
        name == other.name &&
        categories == other.categories &&
        price == other.price &&
        imageUrl == other.imageUrl &&
        description == other.description &&
        onlinestoremodelID == other.onlinestoremodelID &&
        shoppingbagmodelID == other.shoppingbagmodelID;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("ProductModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$name" + ", ");
    buffer.write("categories=" + "$categories" + ", ");
    buffer.write("price=" + (price != null ? price.toString() : "null") + ", ");
    buffer.write("imageUrl=" + "$imageUrl" + ", ");
    buffer.write("description=" + "$description" + ", ");
    buffer.write("onlinestoremodelID=" + "$onlinestoremodelID" + ", ");
    buffer.write("shoppingbagmodelID=" + "$shoppingbagmodelID");
    buffer.write("}");

    return buffer.toString();
  }

  ProductModel copyWith(
      {String id,
      String name,
      String categories,
      double price,
      String imageUrl,
      String description,
      String onlinestoremodelID,
      String shoppingbagmodelID}) {
    return ProductModel(
        id: id ?? this.id,
        name: name ?? this.name,
        categories: categories ?? this.categories,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        description: description ?? this.description,
        onlinestoremodelID: onlinestoremodelID ?? this.onlinestoremodelID,
        shoppingbagmodelID: shoppingbagmodelID ?? this.shoppingbagmodelID);
  }

  ProductModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        categories = json['categories'],
        price = (json['price'] as num)?.toDouble(),
        imageUrl = json['imageUrl'],
        description = json['description'],
        onlinestoremodelID = json['onlinestoremodelID'],
        shoppingbagmodelID = json['shoppingbagmodelID'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categories': categories,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
        'onlinestoremodelID': onlinestoremodelID,
        'shoppingbagmodelID': shoppingbagmodelID
      };

  static final QueryField ID = QueryField(fieldName: "productModel.id");
  static final QueryField NAME = QueryField(fieldName: "name");
  static final QueryField CATEGORIES = QueryField(fieldName: "categories");
  static final QueryField PRICE = QueryField(fieldName: "price");
  static final QueryField IMAGEURL = QueryField(fieldName: "imageUrl");
  static final QueryField DESCRIPTION = QueryField(fieldName: "description");
  static final QueryField ONLINESTOREMODELID =
      QueryField(fieldName: "onlinestoremodelID");
  static final QueryField SHOPPINGBAGMODELID =
      QueryField(fieldName: "shoppingbagmodelID");
  static var schema =
      Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ProductModel";
    modelSchemaDefinition.pluralName = "ProductModels";

    modelSchemaDefinition.authRules = [
      AuthRule(authStrategy: AuthStrategy.PUBLIC, operations: [
        ModelOperation.CREATE,
        ModelOperation.UPDATE,
        ModelOperation.DELETE,
        ModelOperation.READ
      ])
    ];

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: ProductModel.NAME,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: ProductModel.CATEGORIES,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: ProductModel.PRICE,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.double)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: ProductModel.IMAGEURL,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: ProductModel.DESCRIPTION,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: ProductModel.ONLINESTOREMODELID,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: ProductModel.SHOPPINGBAGMODELID,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));
  });
}

class _ProductModelModelType extends ModelType<ProductModel> {
  const _ProductModelModelType();

  @override
  ProductModel fromJson(Map<String, dynamic> jsonData) {
    return ProductModel.fromJson(jsonData);
  }
}
