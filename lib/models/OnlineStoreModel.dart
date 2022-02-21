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

import 'ModelProvider.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the OnlineStoreModel type in your schema. */
@immutable
class OnlineStoreModel extends Model {
  static const classType = const _OnlineStoreModelModelType();
  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final String operationHours;
  final String categories;
  final List<ProductModel> productModel;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  const OnlineStoreModel._internal(
      {@required this.id,
      this.name,
      this.phoneNumber,
      this.address,
      this.operationHours,
      this.categories,
      this.productModel});

  factory OnlineStoreModel(
      {String id,
      String name,
      String phoneNumber,
      String address,
      String operationHours,
      String categories,
      List<ProductModel> productModel}) {
    return OnlineStoreModel._internal(
        id: id == null ? UUID.getUUID() : id,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        operationHours: operationHours,
        categories: categories,
        productModel: productModel != null
            ? List<ProductModel>.unmodifiable(productModel)
            : productModel);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OnlineStoreModel &&
        id == other.id &&
        name == other.name &&
        phoneNumber == other.phoneNumber &&
        address == other.address &&
        operationHours == other.operationHours &&
        categories == other.categories &&
        DeepCollectionEquality().equals(productModel, other.productModel);
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("OnlineStoreModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$name" + ", ");
    buffer.write("phoneNumber=" + "$phoneNumber" + ", ");
    buffer.write("address=" + "$address" + ", ");
    buffer.write("operationHours=" + "$operationHours" + ", ");
    buffer.write("categories=" + "$categories");
    buffer.write("}");

    return buffer.toString();
  }

  OnlineStoreModel copyWith(
      {String id,
      String name,
      String phoneNumber,
      String address,
      String operationHours,
      String categories,
      List<ProductModel> productModel}) {
    return OnlineStoreModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        address: address ?? this.address,
        operationHours: operationHours ?? this.operationHours,
        categories: categories ?? this.categories,
        productModel: productModel ?? this.productModel);
  }

  OnlineStoreModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        phoneNumber = json['phoneNumber'],
        address = json['address'],
        operationHours = json['operationHours'],
        categories = json['categories'],
        productModel = json['productModel'] is List
            ? (json['productModel'] as List)
                .map((e) =>
                    ProductModel.fromJson(new Map<String, dynamic>.from(e)))
                .toList()
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'address': address,
        'operationHours': operationHours,
        'categories': categories,
        'productModel': productModel != null
            ? productModel
                .map((ProductModel e) => e != null ? e.toJson() : null)
                .toList()
            : null
      };

  static final QueryField ID = QueryField(fieldName: "onlineStoreModel.id");
  static final QueryField NAME = QueryField(fieldName: "name");
  static final QueryField PHONENUMBER = QueryField(fieldName: "phoneNumber");
  static final QueryField ADDRESS = QueryField(fieldName: "address");
  static final QueryField OPERATIONHOURS =
      QueryField(fieldName: "operationHours");
  static final QueryField CATEGORIES = QueryField(fieldName: "categories");
  static final QueryField PRODUCTMODEL = QueryField(
      fieldName: "productModel",
      fieldType: ModelFieldType(ModelFieldTypeEnum.model,
          ofModelName: (ProductModel).toString()));
  static var schema =
      Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "OnlineStoreModel";
    modelSchemaDefinition.pluralName = "OnlineStoreModels";

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
        key: OnlineStoreModel.NAME,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: OnlineStoreModel.PHONENUMBER,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: OnlineStoreModel.ADDRESS,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: OnlineStoreModel.OPERATIONHOURS,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: OnlineStoreModel.CATEGORIES,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
        key: OnlineStoreModel.PRODUCTMODEL,
        isRequired: false,
        ofModelName: (ProductModel).toString(),
        associatedKey: ProductModel.ONLINESTOREMODELID));
  });
}

class _OnlineStoreModelModelType extends ModelType<OnlineStoreModel> {
  const _OnlineStoreModelModelType();

  @override
  OnlineStoreModel fromJson(Map<String, dynamic> jsonData) {
    return OnlineStoreModel.fromJson(jsonData);
  }
}
